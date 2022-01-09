#!/bin/bash

__usage="
Usage: build_rootfs [OPTIONS]
Build rk3399 openEuler-root image.
Run in root user.
The target rootfs.img will be generated in the build folder of the directory where the build_rootfs.sh script is located.

Options: 
  -r, --repo REPO_INFO       The URL/path of target repo file or list of repo's baseurls which should be a space separated list.
  -h, --help                 Show command help.
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

build_rootfs() {
    cd $workdir
    if [ -d rootfs ];then rm -rf rootfs; fi
    mkdir rootfs

    if [ ! -d ${tmp_dir} ]; then
        mkdir -p ${tmp_dir}
    else
        rm -rf ${tmp_dir}/*
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
    mkdir -p ${rootfs_dir}/etc/yum.repos.d
    cp ${tmp_dir}/generic.repo ${rootfs_dir}/etc/yum.repos.d/generic.repo
    dnf --installroot=${rootfs_dir}/ install dnf --nogpgcheck -y 
    dnf --installroot=${rootfs_dir}/ makecache
    dnf --installroot=${rootfs_dir}/ install -y alsa-utils wpa_supplicant vim net-tools iproute iputils NetworkManager openssh-server passwd hostname ntp bluez pulseaudio-module-bluetooth linux-firmware parted gdisk
    cp -L /etc/resolv.conf ${rootfs_dir}/etc/resolv.conf
    rm ${workdir}/*rpm
    
    echo "   nameserver 8.8.8.8
   nameserver 114.114.114.114"  > "$workdir/rootfs/etc/resolv.conf"
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

    cp $nonfree_bin_dir/../bin/expand-rootfs.sh ${rootfs_dir}/etc/rc.d/init.d/expand-rootfs.sh
    chmod +x ${rootfs_dir}/etc/rc.d/init.d/expand-rootfs.sh
    LOG "Set auto expand rootfs done."

    cat << EOF | chroot ${rootfs_dir}  /bin/bash
    echo 'openeuler' | passwd --stdin root
    echo openEuler > /etc/hostname
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    chkconfig --add expand-rootfs.sh
    chkconfig expand-rootfs.sh on
EOF

    sed -i 's/#NTP=/NTP=0.cn.pool.ntp.org/g' ${rootfs_dir}/etc/systemd/timesyncd.conf
    sed -i 's/#FallbackNTP=/FallbackNTP=1.asia.pool.ntp.org 2.asia.pool.ntp.org/g' ${rootfs_dir}/etc/systemd/timesyncd.conf

    echo "LABEL=rootfs  / ext4    defaults,noatime 0 0" > ${rootfs_dir}/etc/fstab
    echo "LABEL=boot  /boot vfat    defaults,noatime 0 0" >> ${rootfs_dir}/etc/fstab
    LOG "Set NTP and fstab done."

    if [ -d ${rootfs_dir}/boot/grub2 ]; then
        rm -rf ${rootfs_dir}/boot/grub2
    fi

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
            fi
            mkdir -p ${rootfs_dir}/usr/lib/firmware/brcm
            cp $nonfree_bin_dir/brcmfmac4356-sdio.firefly,firefly-rk3399.txt ${rootfs_dir}/usr/lib/firmware/brcm
        fi
    fi
}

mk_rootfsimg() {
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

    umount ${workdir}/rootfs_tmp
    rmdir ${workdir}/rootfs_tmp

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

if [ ! -d $workdir ]; then
    mkdir $workdir
fi
if [ ! -d ${log_dir} ];then mkdir -p ${log_dir}; fi
trap 'UMOUNT_ALL' EXIT
UMOUNT_ALL
cd $workdir
sed -i 's/rootfs//g' $workdir/.done
LOG "build rootfs..."
if [ -d rootfs ]; then
    if [[ -f $workdir/.param_last && -f ${workdir}/rootfs/etc/fstab ]]; then
        last_branch=$(cat $workdir/.param_last | grep branch)
        last_branch=${branch:7}

        last_dtb_name=$(cat $workdir/.param_last | grep dtb_name)
        last_dtb_name=${dtb_name:9}

        last_repo_file=$(cat $workdir/.param_last | grep repo_file)
        last_repo_file=${repo_file:10}

        if [[ ${last_branch} != ${branch} || ${last_dtb_name} != ${dtb_name} || ${last_repo_file} != ${repo_file} ]]; then
            rm -rf rootfs
            build_rootfs
            trap 'LOSETUP_D_IMG' EXIT
            LOSETUP_D_IMG
            UMOUNT_ALL
            mk_rootfsimg
        fi
    else
        rm -rf rootfs
        build_rootfs
        trap 'LOSETUP_D_IMG' EXIT
        LOSETUP_D_IMG
        UMOUNT_ALL
        mk_rootfsimg
    fi
else
    build_rootfs
    trap 'LOSETUP_D_IMG' EXIT
    LOSETUP_D_IMG
    UMOUNT_ALL
    mk_rootfsimg
fi
LOG "The rootfs.img is generated in the ${workdir}."
echo "rootfs" >> $workdir/.done