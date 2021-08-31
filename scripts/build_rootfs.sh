#!/bin/bash

__usage="
Usage: build-image [OPTIONS]
Build rk3399 rootfs image.
Run in root user.
The target file rootfs.img will be generated in the directory where the build_rootfs.sh script is located

Options: 
  -r, --repo REPO_INFO       Required! The URL/path of target repo file or list of repo's baseurls which should be a space separated list.
  -h, --help                 Show command help.
"

help()
{
    echo "$__usage"
    exit $1
}

used_param() {
    echo ""
    echo "Default args"
    echo "DIR       : $workdir"
    echo ""
    echo "REPO_INFO : $repo_file"
    echo ""    
}

default_param() {
    repo_file="https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo"
    img_name="rootfs.img"
    workdir=$(pwd)/build_dir
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

    mkdir -p rootfs/var/lib/rpm
    rpm --root  rootfs/ --initdb

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
    
    os_release_name=openEuler-release
    dnf ${repo_info} --disablerepo="*" --downloaddir=${workdir}/ download ${os_release_name}
    if [ $? != 0 ]; then
        echo "Fail to download ${os_release_name}!"
        exit 2
    fi
    os_release_name=`ls -r ${workdir}/${os_release_name}*.rpm 2>/dev/null| head -n 1`
    if [ -z "${os_release_name}" ]; then
        echo "${os_release_name} can not be found!"
        exit 2
    fi

    rpm -ivh --nodeps --root $workdir/rootfs/ ${os_release_name}

    mkdir -p ${workdir}/rootfs/etc/rpm
    chmod a+rX ${workdir}/rootfs/etc/rpm
    echo "%_install_langs en_US" > ${workdir}/rootfs/etc/rpm/macros.image-language-conf
    mkdir -p ${workdir}/rootfs/etc/yum.repos.d
    cp ${tmp_dir}/generic.repo ${workdir}/rootfs/etc/yum.repos.d/generic.repo
    dnf --installroot=$workdir/rootfs/ install dnf --nogpgcheck -y 
    dnf --installroot=$workdir/rootfs/ makecache
    dnf --installroot=$workdir/rootfs/ install -y alsa-utils wpa_supplicant vim net-tools iproute iputils NetworkManager openssh-server passwd hostname ntp bluez pulseaudio-module-bluetooth linux-firmware parted gdisk
    cp -L /etc/resolv.conf ${workdir}/rootfs/etc/resolv.conf
    
    if [ -d rootfs/lib/modules ];then rm -rf rootfs/lib/modules; fi
    cp -rfp kernel/kernel-bin/lib/modules rootfs/lib 
    
    echo "   nameserver 8.8.8.8
   nameserver 114.114.114.114"  > "$workdir/rootfs/etc/resolv.conf"
   if [ ! -d ${workdir}/rootfs/etc/sysconfig/network-scripts ]; then mkdir "${workdir}/rootfs/etc/sysconfig/network-scripts"; fi
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
   DEVICE=eth0" > "$workdir/rootfs/etc/sysconfig/network-scripts/ifup-eth0"

    mount --bind /dev $workdir/rootfs/dev
    mount -t proc /proc $workdir/rootfs/proc
    mount -t sysfs /sys $workdir/rootfs/sys

    cp $workdir/../bin/expand-rootfs.sh ${workdir}/rootfs/etc/rc.d/init.d/expand-rootfs.sh
    chmod +x ${workdir}/rootfs/etc/rc.d/init.d/expand-rootfs.sh

    cat << EOF | chroot ${workdir}/rootfs  /bin/bash
    echo 'openeuler' | passwd --stdin root
    echo openEuler > /etc/hostname
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    chkconfig --add expand-rootfs.sh
    chkconfig expand-rootfs.sh on
EOF

    umount -l ${workdir}/rootfs/dev
    umount -l ${workdir}/rootfs/proc
    umount -l ${workdir}/rootfs/sys

    os_name=${repo_url#*raw/}
    if [ "x${os_name:0:12}" == "xopenEuler-20" ]; then
        mkdir  ${workdir}/rootfs/system
        cp -r ${workdir}/../bin/wireless/system/*    ${workdir}/rootfs/system/
        cp   ${workdir}/../bin/wireless/rcS.sh    ${workdir}/rootfs/etc/profile.d/
        cp   ${workdir}/../bin/wireless/enable_bt    ${workdir}/rootfs/usr/bin/
        chmod +x  ${workdir}/rootfs/usr/bin/enable_bt  ${workdir}/rootfs/etc/profile.d/rcS.sh
    fi

    sed -i 's/#NTP=/NTP=0.cn.pool.ntp.org/g' ${workdir}/rootfs/etc/systemd/timesyncd.conf
    sed -i 's/#FallbackNTP=/FallbackNTP=1.asia.pool.ntp.org 2.asia.pool.ntp.org/g' ${workdir}/rootfs/etc/systemd/timesyncd.conf

    cp ${workdir}/../bin/brcmfmac4356-sdio.firefly,firefly-rk3399.txt ${workdir}/rootfs/lib/firmware/brcm

}
root_need
default_param
parseargs "$@" || help $?
used_param

if [ ! -d $workdir ]; then
    mkdir $workdir
fi
tmp_dir=${workdir}/tmp
build_rootfs
