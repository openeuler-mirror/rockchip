#!/bin/bash

__usage="
Usage: build-u-boot [OPTIONS]
Build rk3399 u-boot image.
The target file idbloader.img u-boot.itb will be generated in the directory where the build_u-boot.sh script is located

Options: 
  -c, --config BOARD_CONFIG     Required! The name of target board which should be a space separated list, which defaults to firefly-rk3399_defconfig.
  -h, --help                    Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

default_param() {
    config="firefly-rk3399_defconfig"
    workdir=$(pwd)/build
    u_boot_url="https://gitlab.arm.com/systemready/firmware-build/u-boot.git"
    rk3399_bl31_url="https://github.com/rockchip-linux/rkbin/raw/master/bin/rk33/rk3399_bl31_v1.35.elf"
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
        elif [ "x$1" == "x-c" -o "x$1" == "x--config" ]; then
            config=`echo $2`
            shift
            shift
        else
            echo `date` - ERROR, UNKNOWN params "$@"
            return 2
        fi
    done
}

get_tf-a() {
    cd $workdir
    if [ -f bl31.elf ];then rm bl31.elf; fi
    wget -O bl31.elf ${rk3399_bl31_url}

}

build_u-boot() {
    cd $workdir
    if [ -d u-boot ];then
        cd u-boot
        remote_url_exist=`git remote -v | grep "origin"`
        remote_url=`git ls-remote --get-url origin`
        if [[ ${remote_url_exist} = "" || ${remote_url} != ${u_boot_url} ]]; then
            cd ../
            rm -rf $workdir/u-boot
            git clone -b ${u_boot_ver} ${u_boot_url}
            if [[ $? -eq 0 ]]; then
                LOG "clone u-boot done."
            else
                ERROR "clone u-boot failed."
                exit 1
            fi
        fi
    else
        git clone -b ${u_boot_ver} ${u_boot_url}
    fi
    cd u-boot
    mv $workdir/bl31.elf .
    make ARCH=arm $config
    make ARCH=arm -j$(nproc)
    make ARCH=arm u-boot.itb -j$(nproc)
    if [ -z u-boot.itb ]; then
        echo "u-boot file can not be found!"
        exit 2
    fi

}

set -e
u_boot_ver="v2020.10"
default_param
parseargs "$@" || help $?

if [ ! -d $workdir ]; then
    mkdir $workdir
fi
get_tf-a
build_u-boot
touch $workdir/.u-boot.down