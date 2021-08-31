#!/bin/bash

__usage="
Usage: build [OPTIONS]
Build rk3399 bootable images.
The target bootable compressed images will be generated in the output directory where the build script is located.

Options: 
  -n, --name IMAGE_NAME            The RK3399 image name to be built.
  -k, --kernel KERNEL_URL          The URL of kernel source's repository, which defaults to https://gitee.com/openeuler/rockchip-kernel.git.
  -b, --branch KERNEL_BRANCH       The branch name of kernel source's repository, which defaults to openEuler-20.03-LTS.
  -c, --config BOARD_CONFIG        Required! The name of target board which should be a space separated list.
  -r, --repo REPO_INFO             Required! The URL/path of target repo file or list of repo's baseurls which should be a space separated list.
  -d, --device-tree DTB_NAME       Required! The device tree name of target board.
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
    echo "BOARD_NAME          : $config"
    echo ""    
    echo "DTB_NAME            : $dtb_name"
    echo ""
    echo "OPENEULER_VERSION   : $version"
    echo ""
}

default_param() {
    config=firefly-rk3399_defconfig
    dtb_name=rk3399-firefly
    branch=openEuler-20.03-LTS
    repo_file="https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo"
    kernel_url="https://gitee.com/openeuler/rockchip-kernel.git"
    workdir=$(pwd)/build_dir
    name=${branch}-${dtb_name}-aarch64-alpha1
}


deppkg_install() {
    dnf makecache
    dnf install git wget make gcc bison dtc m4 flex bc openssl-devel tar dosfstools rsync parted dnf-plugins-core tar -y
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
        else
            echo `date` - ERROR, UNKNOWN params "$@"
            return 2
        fi
    done
}

default_param
parseargs "$@" || help $?
used_param
deppkg_install

mkdir $workdir
bash build_u-boot.sh -c $config
bash build_boot.sh -b $branch -d $dtb_name -k $kernel_url
bash build_rootfs.sh -r $repo_file
bash gen_image.sh -n $name