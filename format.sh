#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

detect-drive-name
read -p "Format drive \"$drive_name\"? All data on it will be destroyed, including home partition! [y/N] "
[[ $REPLY =~ ^[Yy] ]] || exit 0

run-script umount $drive_path

disk_size=`sudo parted -s $drive_path unit MB print devices | grep -oP "(?<=^$drive_path \()\d+"`
(( $disk_size >= 2000 )) || fatal-error "The disk size is less than minimum required size of 2GB."

boot_size=260
root_size=$[disk_size / 3]
max_root_size=15000
(( $root_size < $max_root_size )) || root_size=$max_root_size
min_root_size=1500
(( $root_size > $min_root_size )) || root_size=$min_root_size

sudo parted -s -a optimal $drive_path \
  mklabel gpt \
  mkpart EFI fat32 0% ${boot_size}MB \
  set 1 boot on \
  set 1 legacy_boot on \
  mkpart primary ext4 ${boot_size}MB ${root_size}MB \
  mkpart primary ext4 ${root_size}MB 100%

journaling=${2:-on}
[[ $journaling == on ]] || ext4_options="-O ^has_journal"

sudo mkfs.fat -n boot -F 32 `partition-path 1`
sudo mkfs.ext4 -L root ${ext4_options:-} `partition-path 2`
sudo mkfs.ext4 -L home ${ext4_options:-} `partition-path 3`

if [[ $journaling == on ]]; then
  disk_bus=`udevadm info --query=all --name=${drive_path##*/} | grep -oP "(?<= ID_BUS=).+"`
  if [[ $disk_bus =~ ^usb|memstick$ ]]; then
    sudo tune2fs -o journal_data_writeback `partition-path 2`
    sudo tune2fs -o journal_data_writeback `partition-path 3`
  fi
fi

run-script mount $drive_path
