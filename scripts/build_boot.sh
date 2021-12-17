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
    nonfree_bin_dir=${workdir}/../bin
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
    if [ "x$dtb_name" == "xrk3399-firefly" ];then
        cp $workdir/../configs/rk3399-firefly_defconfig kernel/arch/arm64/configs
        cd kernel
        make ARCH=arm64 rk3399-firefly_defconfig
    else
        cp $workdir/../configs/rockchip64_defconfig kernel/arch/arm64/configs
        cd kernel
        make ARCH=arm64 rockchip64_defconfig
    fi
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
    if [ -z $workdir/kernel/arch/arm64/boot/Image ]; then
        echo "kernel Image can not be found!"
        exit 2
    fi
    if [ -d $workdir/kernel-bin ];then rm -rf $workdir/kernel-bin; fi
    mkdir -p $workdir/kernel-bin/boot
    cd $workdir/kernel
    make ARCH=arm64 install INSTALL_PATH=$workdir/kernel-bin/boot
    make ARCH=arm64 modules_install INSTALL_MOD_PATH=$workdir/kernel-bin
    cp arch/arm64/boot/dts/rockchip/${dtb_name}.dtb $workdir/kernel-bin/boot
}

set_cmdline(){
    vmlinuz_name=$(ls $workdir/kernel-bin/boot | grep vmlinuz)
    dtb_name=$(ls $workdir/kernel-bin/boot | grep dtb)
    echo "label openEuler
    kernel /${vmlinuz_name}
    fdt /${dtb_name}
    append  earlyprintk console=ttyS2,1500000 rw root=$1 rootfstype=ext4 init=/sbin/init rootwait" > $2
}

mk_bootdir() {
    mkdir -p $workdir/boot/extlinux
    if [ "x$branch" == "xopenEuler-20.03-LTS" -a "x$dtb_name" == "xrk3399-rock-pi-4a" ]; then
        set_cmdline /dev/mmcblk0p5 $workdir/boot/extlinux/extlinux.conf
    else
        set_cmdline /dev/mmcblk1p5 $workdir/boot/extlinux/extlinux.conf
    fi
    cp -r $workdir/kernel-bin/boot/* $workdir/boot
}

customize_rootfs() {
    cd $workdir
    if [ -d $workdir/rootfs_ext ];then rm -rf $workdir/rootfs_ext; fi
    mkdir $workdir/rootfs_ext
    if [ "x$branch" == "xopenEuler-20.03-LTS" ]; then
        mkdir -p $workdir/rootfs_ext/system
        mkdir -p $workdir/rootfs_ext/etc/profile.d/
        mkdir -p $workdir/rootfs_ext/usr/bin/
        cp -r $nonfree_bin_dir/wireless/system/*    $workdir/rootfs_ext/system/
        cp   $nonfree_bin_dir/wireless/rcS.sh    $workdir/rootfs_ext/etc/profile.d/
        cp   $nonfree_bin_dir/wireless/enable_bt    $workdir/rootfs_ext/usr/bin/
        chmod +x  $workdir/rootfs_ext/usr/bin/enable_bt  $workdir/rootfs_ext/etc/profile.d/rcS.sh
    fi
    mkdir -p $workdir/rootfs_ext/usr/lib/firmware/brcm
    cp $nonfree_bin_dir/brcmfmac4356-sdio.firefly,firefly-rk3399.txt $workdir/rootfs_ext/usr/lib/firmware/brcm
}

default_param
parseargs "$@" || help $?
set -e

if [ ! -d $workdir ]; then
    mkdir $workdir
fi

if [ "x$branch" == "xopenEuler-20.03-LTS" ];then
    build_rockchip-kernel
else
    build_kernel
fi

if [ "x$dtb_name" == "xrk3399-firefly" ]; then
    customize_rootfs
fi

install_kernel
mk_bootdir
touch $workdir/.boot.down