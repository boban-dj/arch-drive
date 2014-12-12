#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

target_arch=${2:-}

run-script mount $drive_path

if [[ `find $mnt_dir -maxdepth 1 -! -name lost+found -a -! -name boot -a -! -name home | sed 1d` ]]; then
  detect-drive-name
  read -p "Install system on \"$drive_name\"? Existing system files will be deleted! [y/N] "
  [[ $REPLY =~ ^[Yy] ]] || exit 0

  mkdir -p /tmp/arch-drive/empty/boot
  sudo rsync -rv --delete --exclude=/lost+found --exclude=/home /tmp/arch-drive/empty/ $mnt_dir
fi

run-script root $drive_path $target_arch
run-script boot $drive_path
