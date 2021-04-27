#!/bin/bash

__usage="
Usage: build-image [OPTIONS]
Build rk3399 rootfs image.
Run in root user.
The target file rootfs.img will be generated in the directory where the build_rootfs.sh script is located

Options: 
  -r, --repo REPO_INFO       Required! The URL/path of target repo file or list of repo's baseurls which should be a space separated list.
  -p, --package PACKAGE      Required! The URL of target package .
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
    echo "PACKAGE   : $openeuler_package"
    echo ""
}

default_param() {
    repo_file="https://gitee.com/src-openeuler/openEuler-repos/raw/openEuler-20.03-LTS/generic.repo"
    img_name="rootfs.img"
    workdir=$(pwd)
    openeuler_package="http://repo.openeuler.org/openEuler-20.03-LTS/everything/aarch64/Packages/openEuler-release-20.03LTS-33.oe1.aarch64.rpm"
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
        elif [ "x$1" == "x-p" -o "x$1" == "x--package" ]; then
            openeuler_package=`echo $2`
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
    mkdir -p rootfs/var/lib/rpm
    rpm --root  /rootfs/ --initdb  
    rpm -ivh --nodeps --root $workdir/rootfs/ $openeuler_package
    mkdir $workdir/rootfs/etc/yum.repos.d 

    if [ "x${repo_file:0:4}" == "xhttp" ]; then
        if [ "x${repo_file:0-5}" == "x.repo" ]; then
            curl -o $workdir/rootfs/etc/yum.repos.d/openEuler-20.03-LTS.repo $repo_file
        fi
    else
        if [ ! -f $repo_file ]; then
            echo `date` - ERROR, repo file $repo_file can not be found.
            exit 2
        else
            cat  $repo_file > "$workdir/rootfs/etc/yum.repos.d/openEuler-20.03-LTS.repo"
        fi
    fi    
    dnf --installroot=$workdir/rootfs/ install dnf --nogpgcheck -y 
    dnf --installroot=$workdir/rootfs/ makecache
    dnf --installroot=$workdir/rootfs/ install -y alsa-utils wpa_supplicant vim net-tools iproute iputils NetworkManager openssh-server passwd hostname ntp bluez pulseaudio-module-bluetooth
    cp -L /etc/resolv.conf ${workdir}/rootfs/etc/resolv.conf
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

    cat << EOF | chroot /root/tmp/rootfs  /bin/bash
    echo 'openeuler' | passwd --stdin root
    echo openEuler > /etc/hostname
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
EOF

    umount -l ${workdir}/rootfs/dev
    umount -l ${workdir}/rootfs/proc
    umount -l ${workdir}/rootfs/sys 

    mkdir  $workdir/rootfs/system
    cp -r $workdir/config/wireless/system/*    ${workdir}/rootfs/system/
    cp   $workdir/config/wireless/rcS.sh    ${workdir}/rootfs/etc/profile.d/
    cp   $workdir/config/wireless/enable_bt    ${workdir}/rootfs/usr/bin/
    chmod +x  $workdir/rootfs/usr/bin/enable_bt  ${workdir}/rootfs/etc/profile.d/rcS.sh  

    echo "Writint image ..."
    dd if=/dev/zero of=rootfs.img bs=1M count=3000
    mkfs.ext4 rootfs.img
    mkdir rootfsimg
    mount rootfs.img rootfsimg/
    cp -rfp rootfs/* rootfsimg/    
    umount rootfsimg/
    e2fsck -p -f rootfs.img  
    resize2fs -M rootfs.img   

}
root_need
default_param
parseargs "$@" || help $?
used_param

build_rootfs
