#!/bin/bash

__usage="
Usage: build_boot [OPTIONS]
Build Rockchip boot image.
The target boot.img will be generated in the build folder of the directory where the build_boot.sh script is located.

Options: 
  -b, --branch KERNEL_BRANCH            The branch name of kernel source's repository, which defaults to openEuler-20.03-LTS.
  -k, --kernel KERNEL_URL               Required! The URL of kernel source's repository.
  -d, --device-tree DTB_NAME            Required! The device tree name of target board, which defaults to rk3399-firefly.
  -p, --platform PLATFORM               Required! The platform of target board, which defaults to rockchip.
  -h, --help                            Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

default_param() {
    workdir=$(pwd)/build
    branch=openEuler-20.03-LTS
    dtb_name=rk3399-firefly
    platform=rockchip
    kernel_url="https://gitee.com/openeuler/rockchip-kernel.git"
    boot_dir=$workdir/boot
    log_dir=$workdir/log
}

local_param(){
    if [ -f $workdir/.param ]; then
        branch=$(cat $workdir/.param | grep branch)
        branch=${branch:7}

        dtb_name=$(cat $workdir/.param | grep dtb_name)
        dtb_name=${dtb_name:9}
        
        platform=$(cat $workdir/.param | grep platform)
        platform=${platform:9}

        kernel_url=$(cat $workdir/.param | grep kernel_url)
        kernel_url=${kernel_url:11}
    fi
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
        elif [ "x$1" == "x-b" -o "x$1" == "x--branch" ]; then
            branch=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-d" -o "x$1" == "x--device-tree" ]; then
            dtb_name=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-k" -o "x$1" == "x--kernel" ]; then
            kernel_url=`echo $2`
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

buildid=$(date +%Y%m%d%H%M%S)
builddate=${buildid:0:8}

ERROR(){
    echo `date` - ERROR, $* | tee -a ${log_dir}/${builddate}.log
}

LOG(){
    echo `date` - INFO, $* | tee -a ${log_dir}/${builddate}.log
}

LOSETUP_D_IMG(){
    set +e
    if [ -d $workdir/boot_emmc ]; then
        if grep -q "$workdir/boot_emmc " /proc/mounts ; then
            umount $workdir/boot_emmc
        fi
    fi
    if [ -d $workdir/boot_emmc ]; then
        rm -rf $workdir/boot_emmc
    fi
    set -e
}

clone_and_check_kernel_source() {
    cd $workdir
    if [ -d kernel ]; then
        if [ -f $workdir/.param_last ]; then
            last_branch=$(cat $workdir/.param_last | grep branch)
            last_branch=${last_branch:7}

            last_dtb_name=$(cat $workdir/.param_last | grep dtb_name)
            last_dtb_name=${last_dtb_name:9}
            
            last_platform_name=$(cat $workdir/.param_last | grep platform)
            last_platform_name=${last_dtb_name:9}

            last_kernel_url=$(cat $workdir/.param_last | grep kernel_url)
            last_kernel_url=${last_kernel_url:11}

            cd $workdir/kernel
            git remote -v update
            lastest_kernel_version=$(git rev-parse @{u})
            local_kernel_version=$(git rev-parse @)
            cd $workdir

            if [[ ${last_branch} != ${branch} || \
            ${last_dtb_name} != ${dtb_name} || \
            ${last_kernel_url} != ${kernel_url} || \
            ${lastest_kernel_version} != ${local_kernel_version} ]]; then
                if [ -d $workdir/kernel ];then rm -rf $workdir/kernel; fi
                if [ -d $workdir/boot ];then rm -rf $workdir/boot; fi
                if [ -f $workdir/boot.img ];then rm $workdir/boot.img; fi
                git clone --depth=1 -b $branch $kernel_url kernel
                LOG "clone kernel source done."
            fi
        fi
    else
        git clone --depth=1 -b $branch $kernel_url kernel
        LOG "clone kernel source done."
    fi
}

build_rockchip-6.6-kernel() {
    cp $workdir/../configs/rockchip64-6.6_defconfig kernel/arch/arm64/configs
    cd $workdir/kernel
    make ARCH=arm64 rockchip64-6.6_defconfig
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

build_rockchip-5.10-kernel() {
    cp $workdir/../configs/rockchip64-5.10_defconfig kernel/arch/arm64/configs
    cd $workdir/kernel
    make ARCH=arm64 rockchip64-5.10_defconfig
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

build_rockchip-4.19-kernel() {
    cp $workdir/../configs/rockchip64-4.19_defconfig kernel/arch/arm64/configs
    cd $workdir/kernel
    make ARCH=arm64 rockchip64_4.19_defconfig
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

build_phytium-5.10-kernel() {
    cd $workdir/kernel
    make ARCH=arm64 phytium_defconfig
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

build_phytium-6.6-kernel() {
    cd $workdir/kernel
    make ARCH=arm64 phytium_defconfig
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

build_rk3588-kernel() {
    cd $workdir/kernel
    make ARCH=arm64 openeuler_rk3588_defconfig
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

install_kernel() {
    if [ ! -f $workdir/kernel/arch/arm64/boot/Image ]; then
        ERROR "kernel Image can not be found!"
        exit 2
    else
        LOG "make kernel done."
    fi
    if [ -d $workdir/kernel/kernel-modules ];then rm -rf $workdir/kernel/kernel-modules; fi
    if [ -d ${boot_dir} ];then rm -rf ${boot_dir}; fi
    mkdir -p ${boot_dir}
    mkdir -p $workdir/kernel/kernel-modules
    cd $workdir/kernel
    make ARCH=arm64 install INSTALL_PATH=${boot_dir}
    make ARCH=arm64 modules_install INSTALL_MOD_PATH=$workdir/kernel/kernel-modules
    LOG "device tree name is ${dtb_name}.dtb"
    cp arch/arm64/boot/dts/${platform}/${dtb_name}.dtb ${boot_dir}
    LOG "prepare kernel done."
}

mk_boot() {
    LOG "start make bootimg..."
    mkdir -p ${boot_dir}/extlinux

    LOG "start gen initrd..."
    dracut --no-kernel ${boot_dir}/initrd.img
    LOG "gen initrd donw."

    kernel_name=$(ls $boot_dir | grep vmlinu)
    dtb_name=$(ls $boot_dir | grep dtb)
    LOG "gen extlinux config for $dtb_name"
    if [ "${platform}" == "rockchip" ];then
        bootargs=${rockchip_bootargs}
    elif [ "${platform}" == "phytium" ];then
        bootargs=${phytium_bootargs}
    else
        echo "Unsupported platform"
        exit 2
    fi
    echo "label openEuler
    kernel /${kernel_name}
    initrd /initrd.img
    fdt /${dtb_name}
    append  ${bootargs}" \
    > ${boot_dir}/extlinux/extlinux.conf

    LOG "gen extlinux config done."

    dd if=/dev/zero of=$workdir/boot.img bs=1M count=240 status=progress
    mkfs.vfat -n boot $workdir/boot.img
    if [ -d $workdir/boot_emmc ];then rm -rf $workdir/boot_emmc; fi
    mkdir $workdir/boot_emmc
    mount $workdir/boot.img $workdir/boot_emmc/
    cp -r ${boot_dir}/* $workdir/boot_emmc/
    umount $workdir/boot.img
    rmdir $workdir/boot_emmc

    if [ -f $workdir/boot.img ]; then
        LOG "make boot image done."
    else
        ERROR "make boot image failed!"
        exit 2
    fi

    LOG "clean boot directory."
    rm -rf ${boot_dir}
}

default_param
local_param
parseargs "$@" || help $?
set -e

rockchip_bootargs="earlyprintk console=ttyS2,1500000 rw root=UUID=614e0000-0000-4b53-8000-1d28000054a9 rootfstype=ext4 init=/sbin/init rootwait"
phytium_bootargs="console=ttyAMA1,115200 earlycon=pl011,0x2800d000 rw root=UUID=614e0000-0000-4b53-8000-1d28000054a9 rootfstype=ext4 rootwait cma=256m"

if [ ! -d $workdir ]; then
    mkdir $workdir
fi
if [ ! -d ${log_dir} ];then mkdir -p ${log_dir}; fi
if [ ! -f $workdir/.done ];then
    touch $workdir/.done
fi
sed -i 's/bootimg//g' $workdir/.done
LOG "build boot..."
clone_and_check_kernel_source

if [[ -f $workdir/kernel/arch/arm64/boot/dts/${platform}/${dtb_name}.dtb && -f $workdir/kernel/arch/arm64/boot/Image ]];then
    LOG "kernel is the latest"
else
    if [ "${platform}" == "rockchip" ];then
        if [ "${branch:0:19}" == "openEuler-20.03-LTS" ];then # include: openEuler-20.03-LTS*
            build_rockchip-4.19-kernel
        elif [ "${branch}" == "openEuler-22.03-LTS-RK3588" ]; then
            build_rk3588-kernel
        elif [ "${branch:0:19}" == "openEuler-22.03-LTS" ]; then # include: openEuler-22.03-LTS*
            build_rockchip-5.10-kernel
        elif [ "${branch:0:19}" == "openEuler-24.03-LTS" ]; then # include: openEuler-24.03-LTS*
            build_rockchip-6.6-kernel
        else
            echo "Unsupported version."
        fi
    elif [ "${platform}" == "phytium" ];then
        if [ "${branch:0:19}" == "openEuler-22.03-LTS" ]; then # include: openEuler-22.03-LTS*
            build_phytium-5.10-kernel
        elif [ "${branch:0:19}" == "openEuler-24.03-LTS" ]; then # include: openEuler-24.03-LTS*
            build_phytium-6.6-kernel
        else
            echo "Unsupported version."
        fi
    else
        echo "Unsupported platform"
        exit 2
    fi
fi
if [[ -f $workdir/boot.img && $(cat $workdir/.done | grep bootimg) == "bootimg" ]];then
    LOG "boot is the latest"
else
    trap 'LOSETUP_D_IMG' EXIT
    LOSETUP_D_IMG
    install_kernel
    mk_boot
fi
LOG "The boot.img is generated in the ${workdir}."
echo "bootimg" >> $workdir/.done
