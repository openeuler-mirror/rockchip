#!/bin/bash

__usage="
Usage: gen-image [OPTIONS]
Generate rk3399 bootable image.
The target compressed bootable images will be generated in the output directory where the build_u-boot.sh script is located

Options: 
  -n, --name IMAGE_NAME         The RK3399 image name to be built.
  -h, --help                    Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

default_param() {
    workdir=$(pwd)/build
    outputdir=$workdir/$(date +'%Y-%m-%d')
    name=openEuler-Firefly-RK3399-aarch64-alpha1
    rootfs_dir=${workdir}/rootfs
    boot_mnt=${workdir}/boot_tmp
    root_mnt=${workdir}/root_tmp
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
    set -e
}

make_img(){
    cd $workdir
    device=""
    LOSETUP_D_IMG
    size=`du -sh --block-size=1MiB ${rootfs_dir} | cut -f 1 | xargs`
    size=$(($size+1150))
    losetup -D
    img_file=${workdir}/${name}.img
    dd if=/dev/zero of=${img_file} bs=1MiB count=$size status=progress && sync

    cat << EOF | parted ${img_file} mklabel gpt mkpart primary 64s 16383s
    Ignore
EOF
    parted ${img_file} mkpart primary 16384s 24575s
    parted ${img_file} mkpart primary 24576s 32767s
    parted ${img_file} mkpart primary fat32 32768s 262143s
    parted ${img_file} -s set 4 boot on
    parted ${img_file} mkpart primary ext4 262144s 100%

    device=`losetup -f --show -P ${img_file}`
    trap 'LOSETUP_D_IMG' EXIT
    kpartx -va ${device}
    loopX=${device##*\/}
    partprobe ${device}
    idbloaderp=/dev/mapper/${loopX}p1
    ubootp=/dev/mapper/${loopX}p2
    trustp=/dev/mapper/${loopX}p3
    bootp=/dev/mapper/${loopX}p4
    rootp=/dev/mapper/${loopX}p5
    
    mkfs.vfat -n boot ${bootp}
    mkfs.ext4 -L rootfs ${rootp}
    mkdir -p ${root_mnt} ${boot_mnt}
    mount -t vfat -o uid=root,gid=root,umask=0000 ${bootp} ${boot_mnt}
    mount -t ext4 ${rootp} ${root_mnt}

    dd if=$workdir/u-boot/idbloader.img of=$idbloaderp
    dd if=$workdir/u-boot/u-boot.itb of=$ubootp
    dd if=/dev/zero of=$trustp bs=1M count=4

    cp -rfp ${workdir}/boot/* ${boot_mnt}
    if [ -d ${rootfs_dir}/lib/modules ];then rm -rf ${rootfs_dir}/lib/modules; fi
    cp -rfp ${workdir}/kernel-bin/lib/modules ${rootfs_dir}/lib
    rsync -avHAXq ${rootfs_dir}/* ${root_mnt}
    sync
    sleep 10

    umount $rootp
    umount $bootp

    dd if=${rootp} of=$workdir/rootfs.img status=progress
    sync

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
    else
        mkdir -p $outputdir
    fi
    mv ${name}.img ${outputdir}
    xz ${outputdir}/${name}.img

    tar -zcvf ${outputdir}/${name}.tar.gz \
    $workdir/../bin/rk3399_loader.bin \
    $workdir/../bin/parameter.gpt \
    $workdir/u-boot/idbloader.img \
    $workdir/u-boot/u-boot.itb \
    $workdir/boot.img \
    $workdir/rootfs.img

    cd $outputdir
    sha256sum ${name}.img.xz >> ${name}.img.xz.sha256sum
    sha256sum ${name}.tar.gz >> ${name}.tar.gz.sha256sum
}

set -e
default_param
parseargs "$@" || help $?
sed -i 's/image//g' $workdir/.down
make_img
outputd
echo "image" >> $workdir/.down