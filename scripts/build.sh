#!/bin/bash

__usage="
Usage: build [OPTIONS]
Build Rockchip bootable images.
The target bootable compressed images will be generated in the build/YYYY-MM-DD folder of the directory where the build script is located.

Options: 
  -n, --name IMAGE_NAME            The Rockchip image name to be built.
  -k, --kernel KERNEL_URL          The URL of kernel source's repository, which defaults to https://gitee.com/openeuler/rockchip-kernel.git.
  -b, --branch KERNEL_BRANCH       The branch name of kernel source's repository, which defaults to openEuler-20.03-LTS.
  -c, --config BOARD_CONFIG        Required! The name of target board which should be a space separated list, which defaults to firefly-rk3399_defconfig.
  -r, --repo REPO_INFO             The URL/path of target repo file or list of repo's baseurls which should be a space separated list.
  -d, --device-tree DTB_NAME       Required! The device tree name of target board, which defaults to rk3399-firefly.
  -s, --spec SPEC                  The image's specification: headless, xfce, ukui, dde or the file path of rpmlist. The default is headless.
  -h, --help                       Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

used_param() {
    echo ""
    echo "Default args"
    echo "CONFIG_NAME          : $config"
    echo ""    
    echo "DTB_NAME             : $dtb_name"
    echo ""
    echo "KERNEL_BRANCH        : $branch"
    echo ""
}

default_param() {
    config=firefly-rk3399_defconfig
    dtb_name=rk3399-firefly
    branch=openEuler-20.03-LTS
    repo_file="https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo"
    kernel_url="https://gitee.com/openeuler/rockchip-kernel.git"
    workdir=$(pwd)/build
    board_type=rk3399
    name=${branch}-${dtb_name}-aarch64-alpha1
}

save_param() {
    if [ -f $workdir/.param_last ]; then
        rm $workdir/.param_last
    fi
    if [ -f $workdir/.param ]; then
        mv $workdir/.param $workdir/.param_last
    fi
    echo "config=$config
dtb_name=$dtb_name
branch=$branch
repo_file=$repo_file
kernel_url=$kernel_url
spec_param=$spec_param" > $workdir/.param
}

deppkg_install() {
    dnf makecache
    dnf install git wget make gcc bison dtc m4 flex bc openssl-devel tar dosfstools rsync parted dnf-plugins-core tar kpartx diffutils dracut -y
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
        elif [ "x$1" == "x-k" -o "x$1" == "x--kernel" ]; then
            kernel_url=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-b" -o "x$1" == "x--branch" ]; then
            branch=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-c" -o "x$1" == "x--config" ]; then
            config=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-r" -o "x$1" == "x--repo" ]; then
            repo_file=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-d" -o "x$1" == "x--device-tree" ]; then
            dtb_name=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-s" -o "x$1" == "x--spec" ]; then
            spec_param=`echo $2`
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

default_param
parseargs "$@" || help $?
used_param
if [ ! -d $workdir ]; then
    mkdir $workdir
fi
save_param
if [ ! -d ${log_dir} ];then mkdir -p ${log_dir}; fi
if [ -f $workdir/.done ];then
    LOG "Checking the previous build."
    if [[ $(cat $workdir/.done | grep u-boot) == "u-boot" && \
    $(cat $workdir/.done | grep bootimg) == "bootimg" && \
    $(cat $workdir/.done | grep rootfs) == "rootfs" && \
    $(cat $workdir/.done | grep image) == "image" ]];then
        LOG "Found complete build, clean build flag."
        rm $workdir/.done
        touch $workdir/.done
    fi
else
    deppkg_install
    touch $workdir/.done
fi

if [[ $(cat $workdir/.done | grep u-boot) != "u-boot" ]];then
    bash build_u-boot.sh
fi

if [[ $(cat $workdir/.done | grep bootimg) != "bootimg" ]];then
    bash build_boot.sh
fi

if [[ $(cat $workdir/.done | grep rootfs) != "rootfs" ]];then
    bash build_rootfs.sh
fi

if [[ "x$dtb_name" == "xrk3588s-roc-pc" || "x$dtb_name" == "xrk3588-firefly-itx-3588j" || "x$dtb_name" == "xrk3588-rock-5b"]]; then
    board_type=rk3588
else
    board_type=rk3399
fi
bash gen_image.sh -n $name -t $board_type