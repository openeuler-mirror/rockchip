#!/bin/bash

__usage="
Usage: build_rootfs [OPTIONS]
Build Rockchip openEuler-root image.
Run in root user.
The target rootfs.img will be generated in the build folder of the directory where the build_rootfs.sh script is located.

Options: 
  -r, --repo REPO_INFO          The URL/path of target repo file or list of repo's baseurls which should be a space separated list.
  -b, --branch KERNEL_BRANCH    The branch name of kernel source's repository, which defaults to openEuler-20.03-LTS.
  -d, --device-tree DTB_NAME    The device tree name of target board, which defaults to rk3399-firefly.
  -s, --spec SPEC               The image's specification: headless, xfce, ukui, dde or the file path of rpmlist. The default is headless.
  -h, --help                    Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

default_param() {
    repo_file="https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo"
    tmp_dir=${workdir}/tmp
    workdir=$(pwd)/build
    dtb_name=rk3399-firefly
    branch=openEuler-20.03-LTS
    nonfree_bin_dir=${workdir}/../bin
    rootfs_dir=${workdir}/rootfs
    log_dir=${workdir}/log
}

local_param(){
    if [ -f $workdir/.param ]; then
        repo_file=$(cat $workdir/.param | grep repo_file)
        repo_file=${repo_file:10}

        branch=$(cat $workdir/.param | grep branch)
        branch=${branch:7}

        dtb_name=$(cat $workdir/.param | grep dtb_name)
        dtb_name=${dtb_name:9}

        spec_param=$(cat $workdir/.param | grep spec_param)
        spec_param=${spec_param:11}
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
        elif [ "x$1" == "x-r" -o "x$1" == "x--repo" ]; then
            repo_file=`echo $2`
            shift
            shift
        elif [ "x$1" == "x-b" -o "x$1" == "x--branch" ]; then
            branch=`echo $2`
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

LOSETUP_D_IMG(){
    set +e
    if [ -d ${workdir}/rootfs_tmp ]; then
        if grep -q "${workdir}/rootfs_tmp " /proc/mounts ; then
            umount ${workdir}/rootfs_tmp
        fi
    fi
    if [ -d ${workdir}/rootfs_tmp ]; then
        rm -rf ${workdir}/rootfs_tmp
    fi
    set -e
}

UMOUNT_ALL(){
    set +e
    if grep -q "${rootfs_dir}/dev " /proc/mounts ; then
        umount -l ${rootfs_dir}/dev
    fi
    if grep -q "${rootfs_dir}/proc " /proc/mounts ; then
        umount -l ${rootfs_dir}/proc
    fi
    if grep -q "${rootfs_dir}/sys " /proc/mounts ; then
        umount -l ${rootfs_dir}/sys
    fi
    set -e
}

root_need() {
    if [[ $EUID -ne 0 ]]; then
        echo "Error:This script must be run as root!" 1>&2
        exit 1
    fi
}

INSTALL_PACKAGES(){
    for item in $(cat $1)
    do
        dnf ${repo_info} --disablerepo="*" --installroot=${rootfs_dir}/ install -y $item --nogpgcheck
        if [ $? == 0 ]; then
            LOG install $item.
        else
            ERROR can not install $item.
        fi
    done
}

build_rootfs() {
    trap 'UMOUNT_ALL' EXIT
    cd $workdir
    if [ -d rootfs ];then rm -rf rootfs; fi
    mkdir rootfs

    if [ ! -d ${tmp_dir} ]; then
        mkdir -p ${tmp_dir}
    else
        rm -rf ${tmp_dir}/*
    fi

    if [ "x$spec_param" == "xheadless" ] || [ "x$spec_param" == "x" ]; then
        :
    elif [ "x$spec_param" == "xxfce" ] || [ "x$spec_param" == "xukui" ] || [ "x$spec_param" == "xdde" ]; then
        CONFIG_RPM_LIST=$workdir/../configs/rpmlist-${spec_param}
    elif [ -f ${spec_param} ]; then
        cp ${spec_param} ${tmp_dir}/
        spec_file_name=${spec_param##*/}
        CONFIG_RPM_LIST=${tmp_dir}/${spec_file_name}
    else
        echo `date` - ERROR, please check your params in option -s or --spec.
        exit 2
    fi

    mkdir -p ${rootfs_dir}/var/lib/rpm
    rpm --root  ${rootfs_dir}/ --initdb

    if [ "x$repo_file" == "x" ] ; then
        echo `date` - ERROR, \"-r REPO_INFO or --repo REPO_INFO\" missing.
        help 2
    elif [ "x${repo_file:0:4}" == "xhttp" ]; then
        if [ "x${repo_file:0-5}" == "x.repo" ]; then
            repo_url=${repo_file}
            wget ${repo_file} -P ${tmp_dir}/
            repo_file_name=${repo_file##*/}
            repo_file=${tmp_dir}/${repo_file_name}
        else
            repo_file_name=tmp.repo
            repo_file_tmp=${tmp_dir}/${repo_file_name}
            index=1
            for baseurl in ${repo_file// / }
            do
                echo [repo${index}] >> ${repo_file_tmp}
                echo name=repo${index} to build rk3399 image >> ${repo_file_tmp}
                echo baseurl=${baseurl} >> ${repo_file_tmp}
                echo enabled=1 >> ${repo_file_tmp}
                echo gpgcheck=0 >> ${repo_file_tmp}
                echo >> ${repo_file_tmp}
                index=$(($index+1))
            done
            repo_file=${repo_file_tmp}
        fi
    else
        if [ ! -f $repo_file ]; then
            echo `date` - ERROR, repo file $repo_file can not be found.
            exit 2
        else
            cp $repo_file ${tmp_dir}/
            repo_file_name=${repo_file##*/}
            repo_file=${tmp_dir}/${repo_file_name}
        fi
    fi

    repo_info_names=`cat ${repo_file} | grep "^\["`
    repo_baseurls=`cat ${repo_file} | grep "^baseurl="`
    index=1
    for repo_name in ${repo_info_names}
    do
        repo_name_list[$index]=${repo_name:1:-1}
        index=$((index+1))
    done
    index=1
    for baseurl in ${repo_baseurls}
    do
        repo_info="${repo_info} --repofrompath ${repo_name_list[$index]}-tmp,${baseurl:8}"
        index=$((index+1))
    done
    
    os_release_name="openEuler-release"
    dnf ${repo_info} --disablerepo="*" --downloaddir=${workdir}/ download ${os_release_name}
    if [ $? != 0 ]; then
        ERROR "Fail to download ${os_release_name}!"
        exit 2
    fi
    os_release_name=`ls -r ${workdir}/${os_release_name}*.rpm 2>/dev/null| head -n 1`
    if [ -z "${os_release_name}" ]; then
        ERROR "${os_release_name} can not be found!"
        exit 2
    else
        LOG "Success to download ${os_release_name}."
    fi

    rpm -ivh --nodeps --root ${rootfs_dir}/ ${os_release_name}

    mkdir -p ${rootfs_dir}/etc/rpm
    chmod a+rX ${rootfs_dir}/etc/rpm
    echo "%_install_langs en_US" > ${rootfs_dir}/etc/rpm/macros.image-language-conf
    INSTALL_PACKAGES $CONFIG_RPM_LIST
    cp -L /etc/resolv.conf ${rootfs_dir}/etc/resolv.conf
    rm ${workdir}/*rpm
    
    echo "   nameserver 8.8.8.8
   nameserver 114.114.114.114"  > "${rootfs_dir}/etc/resolv.conf"
    if [ ! -d ${rootfs_dir}/etc/sysconfig/network-scripts ]; then mkdir "${rootfs_dir}/etc/sysconfig/network-scripts"; fi
    echo "   TYPE=Ethernet
   PROXY_METHOD=none
   BROWSER_ONLY=no
   BOOTPROTO=dhcp
   DEFROUTE=yes
   IPV4_FAILURE_FATAL=no
   IPV6INIT=yes
   IPV6_AUTOCONF=yes
   IPV6_DEFROUTE=yes
   IPV6_FAILURE_FATAL=no
   IPV6_ADDR_GEN_MODE=stable-privacy
   NAME=eth0
   UUID=851a6f36-e65c-3a43-8f4a-78fd0fc09dc9
   ONBOOT=yes
   AUTOCONNECT_PRIORITY=-999
   DEVICE=eth0" > "${rootfs_dir}/etc/sysconfig/network-scripts/ifup-eth0"
    
    LOG "Configure network done."

    mount --bind /dev ${rootfs_dir}/dev
    mount -t proc /proc ${rootfs_dir}/proc
    mount -t sysfs /sys ${rootfs_dir}/sys

    cp $nonfree_bin_dir/../bin/extend-root.sh ${rootfs_dir}/etc/rc.d/init.d/extend-root.sh
    chmod +x ${rootfs_dir}/etc/rc.d/init.d/extend-root.sh

    set +e
    sed -i -e '/^#NTP=/cNTP=0.cn.pool.ntp.org' ${rootfs_dir}/etc/systemd/timesyncd.conf
    sed -i -e 's/#FallbackNTP=/FallbackNTP=1.asia.pool.ntp.org 2.asia.pool.ntp.org /g' ${rootfs_dir}/etc/systemd/timesyncd.conf
    set -e

    cat << EOF | chroot ${rootfs_dir}  /bin/bash
    echo 'openeuler' | passwd --stdin root
    echo openEuler > /etc/hostname
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    chkconfig --add extend-root.sh
    chkconfig extend-root.sh on
EOF

    LOG "Set NTP and auto expand rootfs done."

    echo "LABEL=rootfs  / ext4    defaults,noatime 0 0" > ${rootfs_dir}/etc/fstab
    echo "LABEL=boot  /boot vfat    defaults,noatime 0 0" >> ${rootfs_dir}/etc/fstab
    LOG "Set fstab done."

    if [ -f $workdir/.param ]; then
        dtb_name=$(cat $workdir/.param | grep dtb_name)
        dtb_name=${dtb_name:9}
        if [ "x$dtb_name" == "xrk3399-firefly" ]; then
            cd $workdir
            if [ "x$branch" == "xopenEuler-20.03-LTS" ]; then
                mkdir -p ${rootfs_dir}/system
                mkdir -p ${rootfs_dir}/etc/profile.d/
                mkdir -p ${rootfs_dir}/usr/bin/
                cp -r $nonfree_bin_dir/wireless/system/*    ${rootfs_dir}/system/
                cp   $nonfree_bin_dir/wireless/rcS.sh    ${rootfs_dir}/etc/profile.d/
                cp   $nonfree_bin_dir/wireless/enable_bt    ${rootfs_dir}/usr/bin/
                chmod +x  ${rootfs_dir}/usr/bin/enable_bt  ${rootfs_dir}/etc/profile.d/rcS.sh
                LOG "install firefly-rk3399 wireless firmware done."
                ln -s ${rootfs_dir}/system/etc/firmware ${rootfs_dir}/etc/firmware
            fi
            mkdir -p ${rootfs_dir}/usr/lib/firmware/brcm
            cp $nonfree_bin_dir/linux-firmware/ap6356s/brcmfmac4356-sdio.bin ${rootfs_dir}/usr/lib/firmware/brcm
            cp $nonfree_bin_dir/linux-firmware/ap6356s/brcmfmac4356-sdio.firefly,firefly-rk3399.txt ${rootfs_dir}/usr/lib/firmware/brcm
            cp $nonfree_bin_dir/linux-firmware/ap6356s/BCM4356A2.hcd ${rootfs_dir}/usr/lib/firmware/brcm
        elif [ "x$dtb_name" == "xrk3588-firefly-itx-3588j" ]; then
            cd $workdir
            mkdir -p ${rootfs_dir}/etc/modules-load.d/
            echo "8821cu" >> ${rootfs_dir}/etc/modules-load.d/8821cu.conf
        elif [ "x$dtb_name" == "xrk3566-roc-pc" ];then
            mkdir -p ${rootfs_dir}/usr/lib/firmware/brcm
            cp $nonfree_bin_dir/linux-firmware/ap6255/brcmfmac43455-sdio.bin ${rootfs_dir}/usr/lib/firmware/brcm/brcmfmac43455-sdio.firefly,rk3566-roc-pc.bin
            cp $nonfree_bin_dir/linux-firmware/ap6255/brcmfmac43455-sdio.txt ${rootfs_dir}/usr/lib/firmware/brcm/brcmfmac43455-sdio.firefly,rk3566-roc-pc.txt
            cp $nonfree_bin_dir/linux-firmware/ap6255/BCM4345C0.hcd ${rootfs_dir}/usr/lib/firmware/brcm
        elif [ "x$dtb_name" == "xrk3568-roc-pc-se" ];then
            mkdir -p ${rootfs_dir}/usr/lib/firmware/brcm
            cp $nonfree_bin_dir/linux-firmware/ap6275s/brcmfmac43752-sdio.bin ${rootfs_dir}/usr/lib/firmware/brcm/brcmfmac43752-sdio.firefly,rk3568-roc-pc-se.bin
            cp $nonfree_bin_dir/linux-firmware/ap6275s/brcmfmac43752-sdio.txt ${rootfs_dir}/usr/lib/firmware/brcm/brcmfmac43752-sdio.firefly,rk3568-roc-pc-se.txt
            cp $nonfree_bin_dir/linux-firmware/ap6275s/BCM4362A2.hcd ${rootfs_dir}/usr/lib/firmware/brcm
        fi
    fi
    UMOUNT_ALL
}

mk_rootfsimg() {
    trap 'LOSETUP_D_IMG' EXIT
    cd $workdir
    size=`du -sh --block-size=1MiB ${rootfs_dir} | cut -f 1 | xargs`
    size=$(($size+500))
    rootfs_img=${workdir}/rootfs.img
    dd if=/dev/zero of=${rootfs_img} bs=1MiB count=$size status=progress && sync
    mkfs.ext4 -L rootfs ${workdir}/rootfs.img

    if [ -d ${workdir}/rootfs_tmp ];then rm -rf ${workdir}/rootfs_tmp; fi
    mkdir ${workdir}/rootfs_tmp
    mount ${workdir}/rootfs.img ${workdir}/rootfs_tmp

    rsync -avHAXq ${rootfs_dir}/* ${workdir}/rootfs_tmp
    sync
    sleep 10

    LOSETUP_D_IMG

    if [ -f $workdir/rootfs.img ]; then
        LOG "make rootfs image done."
    else
        ERROR "make rootfs image failed!"
        exit 2
    fi

    LOG "clean rootfs directory."
    rm -rf ${rootfs_dir}
}
set -e
root_need
default_param
local_param
parseargs "$@" || help $?

CONFIG_RPM_LIST=$workdir/../configs/rpmlist

if [ ! -d $workdir ]; then
    mkdir $workdir
fi
if [ ! -d ${log_dir} ];then mkdir -p ${log_dir}; fi
if [ ! -f $workdir/.done ];then
    touch $workdir/.done
fi
cd $workdir
sed -i 's/rootfs//g' $workdir/.done
LOG "build rootfs..."
if [ -d rootfs ]; then
    if [[ -f $workdir/rootfs.img && $(cat $workdir/.done | grep rootfs) == "rootfs" ]];then
        last_branch=$(cat $workdir/.param_last | grep branch)
        last_branch=${last_branch:7}

        last_dtb_name=$(cat $workdir/.param_last | grep dtb_name)
        last_dtb_name=${last_dtb_name:9}

        last_repo_file=$(cat $workdir/.param_last | grep repo_file)
        last_repo_file=${last_repo_file:10}

        last_spec_param=$(cat $workdir/.param_last | grep spec_param)
        last_spec_param=${last_spec_param:11}

        if [[ ${last_branch} != ${branch} || ${last_dtb_name} != ${dtb_name} || ${last_repo_file} != ${repo_file} || ${last_spec_param} != ${spec_param} ]]; then
            rm -rf rootfs
            build_rootfs
            mk_rootfsimg
        fi
    else
        rm -rf rootfs
        build_rootfs
        mk_rootfsimg
    fi
else
    build_rootfs
    mk_rootfsimg
fi
LOG "The rootfs.img is generated in the ${workdir}."
echo "rootfs" >> $workdir/.done
