#!/bin/bash

# chkconfig: - 99 10
# description: expand rootfs


ROOT_PART="$(findmnt / -o source -n)"  # /dev/mmcblk1p5
ROOT_DEV="/dev/$(lsblk -no pkname "$ROOT_PART")"  # /dev/mmcblk1
PART_NUM="$(echo "$ROOT_PART" | grep -o "[[:digit:]]*$")"  # 5

cat << EOF | gdisk $ROOT_DEV
p
w
Y
Y
EOF

parted -s $ROOT_DEV -- resizepart $PART_NUM 100%
resize2fs $ROOT_PART

ln -s /system/etc/firmware /etc/firmware

if [ -f /etc/rc.d/init.d/expand-rootfs.sh ];then rm /etc/rc.d/init.d/expand-rootfs.sh; fi
