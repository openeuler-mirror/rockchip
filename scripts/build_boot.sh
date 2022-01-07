#!/bin/bash

__usage="
Usage: build-boot [OPTIONS]
Build rk3399 boot image.
The target directory boot will be generated in the build folder of the directory where the build_boot.sh script is located.

Options: 
  -b, --branch KERNEL_BRANCH            The branch name of kernel source's repository, which defaults to openEuler-20.03-LTS.
  -k, --kernel KERNEL_URL               Required! The URL of kernel source's repository.
  -d, --device-tree DTB_NAME            Required! The device tree name of target board, which defaults to rk3399-firefly.
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
    kernel_url="https://gitee.com/openeuler/rockchip-kernel.git"
}

local_param(){
    if [ -f $workdir/.param ]; then
        branch=$(cat $workdir/.param | grep branch)
        branch=${branch:7}

        dtb_name=$(cat $workdir/.param | grep dtb_name)
        dtb_name=${dtb_name:9}

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
        else
            echo `date` - ERROR, UNKNOWN params "$@"
            return 2
        fi
    done
}

buildid=$(date +%Y%m%d%H%M%S)
builddate=${buildid:0:8}

ERROR(){
    echo `date` - ERROR, $* | tee -a ${workdir}/${builddate}.log
}

LOG(){
    echo `date` - INFO, $* | tee -a ${workdir}/${builddate}.log
}

set_cmdline(){
    vmlinuz_name=$(ls $workdir/kernel-bin/boot | grep vmlinuz)
    dtb_name=$(ls $workdir/kernel-bin/boot | grep dtb)
    echo "label openEuler
    kernel /${vmlinuz_name}
    fdt /${dtb_name}
    append  earlyprintk console=ttyS2,1500000 rw root=$1 rootfstype=ext4 init=/sbin/init rootwait" > $2
}

clone_and_check_kernel_source() {
    cd $workdir
    if [ -d kernel ]; then
        if [ -f $workdir/.param_last ]; then
            last_branch=$(cat $workdir/.param_last | grep branch)
            last_branch=${branch:7}

            last_dtb_name=$(cat $workdir/.param_last | grep dtb_name)
            last_dtb_name=${dtb_name:9}

            last_kernel_url=$(cat $workdir/.param_last | grep kernel_url)
            last_kernel_url=${kernel_url:11}

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
                LOG "clone kernel source down."
            fi
        fi
    else
        git clone --depth=1 -b $branch $kernel_url kernel
        LOG "clone kernel source down."
    fi
}

build_kernel() {
    cd $workdir
    if [ "x$dtb_name" == "xrk3399-firefly" ];then
        cp $workdir/../configs/rk3399-firefly_5.10.0_defconfig kernel/arch/arm64/configs
        cd kernel
        make ARCH=arm64 rk3399-firefly_5.10.0_defconfig
    else
        cp $workdir/../configs/rockchip64_defconfig kernel/arch/arm64/configs
        cd kernel
        make ARCH=arm64 rockchip64_defconfig
    fi
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

build_rockchip-kernel() {
    cp $workdir/../configs/rockchip64_4.19.90_defconfig kernel/arch/arm64/configs
    cd $workdir/kernel
    make ARCH=arm64 rockchip64_4.19.90_defconfig
    LOG "make kernel begin..."
    make ARCH=arm64 -j$(nproc)
}

install_kernel() {
    if [ -z $workdir/kernel/arch/arm64/boot/Image ]; then
        ERROR "kernel Image can not be found!"
        exit 2
    else
        LOG "make kernel down."
    fi
    if [ -d $workdir/kernel-bin ];then rm -rf $workdir/kernel-bin; fi
    mkdir -p $workdir/kernel-bin/boot
    cd $workdir/kernel
    make ARCH=arm64 install INSTALL_PATH=$workdir/kernel-bin/boot
    make ARCH=arm64 modules_install INSTALL_MOD_PATH=$workdir/kernel-bin
    cp $workdir/kernel/arch/arm64/boot/dts/rockchip/${dtb_name}.dtb $workdir/kernel-bin/boot
    LOG "prepare kernel down."
}

mk_boot() {
    if [ -d $workdir/boot ];then rm -rf $workdir/boot; fi
    mkdir -p $workdir/boot/extlinux
    if [ "x$branch" == "xopenEuler-20.03-LTS" -a "x$dtb_name" == "xrk3399-rock-pi-4a" ]; then
        set_cmdline /dev/mmcblk0p5 $workdir/boot/extlinux/extlinux.conf
    else
        set_cmdline /dev/mmcblk1p5 $workdir/boot/extlinux/extlinux.conf
    fi
    cp -r $workdir/kernel-bin/boot/* $workdir/boot

    set_cmdline /dev/mmcblk2p5 $workdir/boot/extlinux/extlinux.conf.emmc

    if [ -d $workdir/boot ]; then
        LOG "make boot down."
    else
        ERROR "make boot failed!"
        exit 2
    fi
}

default_param
local_param
parseargs "$@" || help $?
set -e

if [ ! -d $workdir ]; then
    mkdir $workdir
fi
sed -i 's/bootdir//g' $workdir/.down
clone_and_check_kernel_source

if [[ -f $workdir/kernel/arch/arm64/boot/dts/rockchip/${dtb_name}.dtb && -f $workdir/kernel/arch/arm64/boot/Image ]];then
    echo "kernel is the latest"
else
    if [ "x$branch" == "xopenEuler-20.03-LTS" ];then
        build_rockchip-kernel
    else
        build_kernel
    fi
fi
if [[ -f $workdir/boot/${dtb_name}.dtb && -f $workdir/boot_emmc/${dtb_name}.dtb ]];then
    echo "boot is the latest"
else
    install_kernel
    mk_boot
fi
echo "bootdir" >> $workdir/.down
