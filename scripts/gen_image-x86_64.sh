#!/bin/bash

__usage="
Usage: gen_image [OPTIONS]
Generate Rockchip bootable image.
The target compressed bootable images will be generated in the build/YYYY-MM-DD folder of the directory where the gen_image.sh script is located.

Options: 
  -n, --name IMAGE_NAME         The RK3588 image name to be built.
  -h, --help                    Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

default_param() {
    workdir=$(pwd)/build
    bindir=$(pwd)/bin/rk3588-pack
    outputdir=${workdir}/$(date +'%Y-%m-%d')
    name=openEuler-22.03-LTS-RK3588
    rootfs_dir=${workdir}/rootfs
    boot_dir=${workdir}/boot
    uboot_dir=${workdir}/u-boot
    boot_mnt=${workdir}/boot_tmp
    emmc_boot_mnt=${workdir}/emmc_boot_tmp
    root_mnt=${workdir}/root_tmp
    log_dir=${workdir}/log
}

buildid=$(date +%Y%m%d%H%M%S)
builddate=${buildid:0:8}

ERROR(){
    echo `date` - ERROR, $* | tee -a ${log_dir}/${builddate}.log
}

LOG(){
    echo `date` - INFO, $* | tee -a ${log_dir}/${builddate}.log
}

prepare_bin(){
    cp -rf ${bindir}/afptool ${workdir}
    cp -rf ${bindir}/rkImageMaker ${workdir}
}

prepare_img(){
    mkdir -p ${workdir}/Image
    cp -rf ${bindir}/* ${workdir}/Image/
    cp -rf ${workdir}/boot.img ${workdir}/Image/
    cp -rf ${workdir}/rootfs.img ${workdir}/Image/
}

make_img(){
    cp -rf ${workdir}/Image/package-file ${workdir}
    echo "start to make update.img..."
    if [ ! -f "${workdir}/Image/parameter" -a ! -f "${workdir}/Image/parameter.txt" ]; then
        echo "Error:No found parameter!"
        exit 1
    fi
    if [ ! -f "${workdir}/package-file" ]; then
        echo "Error:No found package-file!"
        exit 1
    fi
    
    chmod +x ${workdir}/afptool
    chmod +x ${workdir}/rkImageMaker
    ${workdir}/afptool -pack ${workdir}/ ${workdir}/Image/update.img || pause
    ${workdir}/rkImageMaker -RK3588 ${workdir}/Image/MiniLoaderAll.bin ${workdir}/Image/update.img ${workdir}/update.img -os_type:androidos || pause

    mv ${workdir}/update.img ${workdir}/${name}.img
}

LOG "gen image..."
default_param
prepare_bin
prepare_img
make_img
echo "image" >> $workdir/.done
