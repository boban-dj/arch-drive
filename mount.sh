#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

block_info=`sudo blkid`
check-partition() {
  partition_path=`partition-path $1`
  partition_info=`echo "$block_info" | grep "^$partition_path: "`
  [[ $partition_info == *" LABEL=\"$3\""* && $partition_info == *" TYPE=\"$2\""* ]]
}
check-partition 1 vfat boot && check-partition 2 ext4 root && check-partition 3 ext4 home || fatal-error "The selected drive is not properly formatted and can not be mounted."

mounted_drive_path=`mounted-drive-path $mnt_dir`
[[ -z $mounted_drive_path || $mounted_drive_path == $drive_path ]] || run-script umount $mounted_drive_path

mkdir -p $mnt_dir
mountpoint -q $mnt_dir || sudo mount `partition-path 2` $mnt_dir

sudo mkdir -p $mnt_dir/boot
mountpoint -q $mnt_dir/boot || sudo mount `partition-path 1` $mnt_dir/boot

sudo mkdir -p $mnt_dir/home
mountpoint -q $mnt_dir/home || sudo mount `partition-path 3` $mnt_dir/home
