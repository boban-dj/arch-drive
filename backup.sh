#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

run-script mount $drive_path

if [[ ! `find $mnt_dir/home -maxdepth 1 -! -name lost+found | sed 1d` ]]; then
  echo "Home partition is empty."
  exit
fi

mkdir -p ~/Downloads/arch-drive-home
sudo rsync -a --delete --exclude=/lost+found --info=progress2 $mnt_dir/home/ ~/Downloads/arch-drive-home
