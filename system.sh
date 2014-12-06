#!/bin/bash
. ${BASH_SOURCE[0]%/*}/common.sh

select-drive

run-script mount $drive_path

if [[ `find $mnt_dir -maxdepth 1 -! -name lost+found -a -! -name boot -a -! -name home | sed 1d` ]]; then
  read -p "Install system on \"`drive-name`\"? Existing system will be destroyed! [y/N] "
  [[ $REPLY =~ ^[Yy] ]] || exit

  mkdir -p /tmp/arch-drive/empty/boot
  sudo rsync -r --delete --exclude=/lost+found --exclude=/home --info=progress2 /tmp/arch-drive/empty/ $mnt_dir
fi

run-script root $drive_path
run-script boot $drive_path
