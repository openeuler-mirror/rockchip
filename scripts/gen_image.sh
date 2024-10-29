#!/bin/bash

__usage="
Usage: gen_image [OPTIONS]
Generate Rockchip bootable image.
The target compressed bootable images will be generated in the build/YYYY-MM-DD folder of the directory where the gen_image.sh script is located.

Options: 
  -n, --name IMAGE_NAME         The Rockchip image name to be built.
  -t, --type BOARD_TYPE         Board Soc type.
  -p, --platform PLATFORM       Required! The platform of target board, which defaults to rockchip.
  -h, --help                    Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

default_param() {
    workdir=$(pwd)/build
    outputdir=${workdir}/$(date +'%Y-%m-%d')
    name=openEuler-Firefly-RK3399-aarch64-alpha1
    board_type=rk3399
    platform=rockchip
    rootfs_dir=${workdir}/rootfs
    boot_dir=${workdir}/boot
    uboot_dir=${workdir}/u-boot
    boot_mnt=${workdir}/boot_tmp
    emmc_boot_mnt=${workdir}/emmc_boot_tmp
    root_mnt=${workdir}/root_tmp
    log_dir=${workdir}/log
}

parseargs()
{
    if [ "x$#" == "x0" ]; then
        return 0
    fi

    while [ "x$#" != "x0" ];
    do
        if [ "x$1" == "x-h" -o "x$1" == "x--help" ]; then
            return 1
        elif [ "x$1" == "x" ]; then
            shift
        elif [ "x$1" == "x-n" -o "x$1" == "x--name" ]; then
            name=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-t" -o "x$1" == "x--type" ]; then
            board_type=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-p" -o "x$1" == "x--platform" ]; then
            platform=`echo $2`
            shift
            shift
        else
            echo `date` - ERROR, UNKNOWN params "$@"
            return 2
        fi
    done
}

LOSETUP_D_IMG(){
    set +e
    if [ -d ${root_mnt} ]; then
        if grep -q "${root_mnt} " /proc/mounts ; then
            umount ${root_mnt}
        fi
    fi
    if [ -d ${boot_mnt} ]; then
        if grep -q "${boot_mnt} " /proc/mounts ; then
            umount ${boot_mnt}
        fi
    fi
    if [ -d ${emmc_boot_mnt} ]; then
        if grep -q "${emmc_boot_mnt} " /proc/mounts ; then
            umount ${emmc_boot_mnt}
        fi
    fi
    if [ -d ${rootfs_dir} ]; then
        if grep -q "${rootfs_dir} " /proc/mounts ; then
            umount ${rootfs_dir}
        fi
    fi
    if [ -d ${boot_dir} ]; then
        if grep -q "${boot_dir} " /proc/mounts ; then
            umount ${boot_dir}
        fi
    fi
    if [ "x$device" != "x" ]; then
        kpartx -d ${device}
        losetup -d ${device}
        device=""
    fi
    if [ -d ${root_mnt} ]; then
        rm -rf ${root_mnt}
    fi
    if [ -d ${boot_mnt} ]; then
        rm -rf ${boot_mnt}
    fi
    if [ -d ${emmc_boot_mnt} ]; then
        rm -rf ${emmc_boot_mnt}
    fi
    if [ -d ${rootfs_dir} ]; then
        rm -rf ${rootfs_dir}
    fi
    if [ -d ${boot_dir} ]; then
        rm -rf ${boot_dir}
    fi
    set -e
}

buildid=$(date +%Y%m%d%H%M%S)
builddate=${buildid:0:8}

ERROR(){
    echo `date` - ERROR, $* | tee -a ${log_dir}/${builddate}.log
}

LOG(){
    echo `date` - INFO, $* | tee -a ${log_dir}/${builddate}.log
}

make_img(){
    cd $workdir

    if [[ -f $workdir/boot.img && $(cat $workdir/.done | grep bootimg) == "bootimg" ]];then
        LOG "boot.img check done."
    else
        ERROR "boot.img check failed, please re-run build_boot.sh."
        exit 2
    fi
    if [[ -f $workdir/rootfs.img && $(cat $workdir/.done | grep rootfs) == "rootfs" ]];then
        LOG "rootfs.img check done."
    else
        ERROR "rootfs.img check failed, please re-run build_rootfs.sh."
        exit 2
    fi

    device=""
    LOSETUP_D_IMG
    size=`du -sh --block-size=1MiB ${workdir}/rootfs.img | cut -f 1 | xargs`
    size=$(($size+1100))
    losetup -D
    img_file=${workdir}/${name}.img
    dd if=/dev/zero of=${img_file} bs=1MiB count=$size status=progress && sync

    parted ${img_file} mklabel gpt mkpart primary fat32 32768s 524287s
    parted ${img_file} -s set 1 boot on
    parted ${img_file} mkpart primary ext4 524288s 100%

    device=`losetup -f --show -P ${img_file}`
    trap 'LOSETUP_D_IMG' EXIT
    kpartx -va ${device}
    loopX=${device##*\/}
    partprobe ${device}

    bootp=/dev/mapper/${loopX}p1
    rootp=/dev/mapper/${loopX}p2
    LOG "make image partitions done."
    
    mkfs.vfat -n boot ${bootp}
    mkfs.ext4 -L rootfs ${rootp}
    LOG "make filesystems done."
    mkdir -p ${root_mnt} ${boot_mnt}
    mount -t vfat -o uid=root,gid=root,umask=0000 ${bootp} ${boot_mnt}
    mount -t ext4 ${rootp} ${root_mnt}

    if [ -d ${rootfs_dir} ];then rm -rf ${rootfs_dir}; fi
    mkdir ${rootfs_dir}
    mount $workdir/rootfs.img ${rootfs_dir}
    if [ -d ${boot_dir} ];then rm -rf ${boot_dir}; fi
    mkdir ${boot_dir}
    mount $workdir/boot.img ${boot_dir}

    cp -rfp ${boot_dir}/* ${boot_mnt}
    line=$(blkid | grep $rootp)
    uuid=${line#*UUID=\"}
    uuid=${uuid%%\"*}
    sed -i "s|UUID=614e0000-0000-4b53-8000-1d28000054a9|UUID=${uuid}|g" ${boot_mnt}/extlinux/extlinux.conf

    rsync -avHAXq ${rootfs_dir}/* ${root_mnt}
    sync
    sleep 10
    LOG "copy openEuler-root done."

    if [ -d ${root_mnt}/lib/modules ];then rm -rf ${root_mnt}/lib/modules; fi
    cp -rfp $workdir/kernel/kernel-modules/lib/modules ${root_mnt}/lib
    LOG "install kernel modules done."

    umount $rootp
    umount $bootp
    umount ${rootfs_dir}
    umount ${boot_dir}
    
    if [ "${platform}" == "rockchip" ];then
        echo "Installing Rockchip U-Boot..."

        if [ -f ${uboot_dir}/idbloader.img ]; then
            dd if=${uboot_dir}/idbloader.img of=/dev/${loopX} seek=64
        else
            ERROR "u-boot idbloader file can not be found!"
            exit 2
        fi
    
        if [ -f ${uboot_dir}/u-boot.itb ]; then
            dd if=${uboot_dir}/u-boot.itb of=/dev/${loopX} seek=16384
        else
            ERROR "u-boot.itb file can not be found!"
            exit 2
        fi
        
    elif [ "${platform}" == "phytium" ];then
        echo "Installing Phytium U-Boot..."
        if [ -f ${uboot_dir}/fip-all-sd-boot.bin ]; then
            sfdisk --dump /dev/${loopX} > ${uboot_dir}/part.txt
            dd if=${uboot_dir}/fip-all-sd-boot.bin of=/dev/${loopX}
            sfdisk --no-reread /dev/${loopX} < ${uboot_dir}/part.txt
        else
            ERROR "phytium fip-all-sd-boot file can not be found!"
            exit 2
        fi
    else
        echo "Unsupported platform"
    fi
    
    LOG "install u-boot done."

    LOSETUP_D_IMG
    losetup -D
}

outputd(){
    cd $workdir

    if [ -f $outputdir ];then
        img_name_check=$(ls $outputdir | grep $name)
        if [ "x$img_name_check" != "x" ]; then
            rm ${name}.img*
            rm ${name}.tar.gz*
        fi
    else
        mkdir -p $outputdir
    fi
    mv ${name}.img ${outputdir}
    LOG "xz openEuler image begin..."
    xz ${outputdir}/${name}.img
    if [ ! -f ${outputdir}/${name}.img.xz ]; then
        ERROR "xz openEuler image failed!"
        exit 2
    else
        LOG "xz openEuler image success."
    fi

    if [[ "x$board_type" == "xrk3399" && "x$platform" == "xrockchip" ]]; then
        LOG "tar openEuler image begin..."
        cp $workdir/../bin/rk3399_loader.bin $workdir
        cp $workdir/../bin/rk3399_parameter.gpt $workdir
        cp $workdir/u-boot/idbloader.img $workdir
        cp $workdir/u-boot/u-boot.itb $workdir
        cd $workdir
        tar -zcvf ${outputdir}/${name}.tar.gz \
        rk3399_loader.bin \
        rk3399_parameter.gpt \
        idbloader.img \
        u-boot.itb \
        boot.img \
        rootfs.img
        if [ ! -f ${outputdir}/${name}.tar.gz ]; then
            ERROR "tar openEuler image failed!"
            exit 2
        else
            LOG "tar openEuler image success."
        fi
        rm $workdir/rk3399_loader.bin
        rm $workdir/rk3399_parameter.gpt
        rm $workdir/idbloader.img
        rm $workdir/u-boot.itb

        cd $outputdir
        sha256sum ${name}.tar.gz >> ${name}.tar.gz.sha256sum
    fi
    cd $outputdir
    sha256sum ${name}.img.xz >> ${name}.img.xz.sha256sum

    LOG "The target images are generated in the ${outputdir}."
}

set -e
default_param
parseargs "$@" || help $?
if [ ! -d ${log_dir} ];then mkdir -p ${log_dir}; fi
if [ ! -f $workdir/.done ];then
    touch $workdir/.done
fi
sed -i 's/image//g' $workdir/.done
LOG "gen image..."
make_img
outputd
echo "image" >> $workdir/.done
