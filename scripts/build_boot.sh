#!/bin/bash

__usage="
Usage: build-boot [OPTIONS]
Build rk3399 boot image.
The target file boot.img will be generated in the directory where the build_boot.sh script is located

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

build_kernel() {
    cd $workdir
    if [ -d kernel ];then
        rm -rf kernel
    fi
    git clone --depth=1 -b $branch $kernel_url
    cp $workdir/../configs/rockchip64_defconfig kernel/arch/arm64/configs
    cd kernel
    make ARCH=arm64 rockchip64_defconfig
    make ARCH=arm64 -j$(nproc)

}

build_rockchip-kernel() {
    cd $workdir
    if [ -d kernel ];then
        rm -rf kernel
    fi
    git clone --depth=1 -b $branch $kernel_url kernel
    cp $workdir/../configs/firefly_4_defconfig kernel/arch/arm64/configs
    cd kernel
    make ARCH=arm64 firefly_4_defconfig
    make ARCH=arm64 -j$(nproc)
}

install_kernel() {
    cd $workdir/kernel
    if [ -z arch/arm64/boot/Image ]; then
        echo "kernel Image can not be found!"
        exit 2
    fi
    if [ -d kernel-bin ];then rm -rf kernel-bin; fi
    mkdir -p kernel-bin/boot
    make ARCH=arm64 install INSTALL_PATH=kernel-bin/boot
    make ARCH=arm64 modules_install INSTALL_MOD_PATH=kernel-bin
    cp arch/arm64/boot/dts/rockchip/${dtb_name}.dtb kernel-bin/boot
}

mk_bootdir() {
    cd $workdir
    mkdir -p boot/extlinux
    cp -r $workdir/kernel/kernel-bin/boot/* $workdir/boot
}

default_param
parseargs "$@" || help $?

if [ ! -d $workdir ]; then
    mkdir $workdir
fi

if [ "x$branch" == "xopenEuler-20.03-LTS" ];then
    build_rockchip-kernel
else
    build_kernel
fi

install_kernel
mk_bootdir
