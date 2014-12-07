#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

run-script mount $drive_path

mkdir -p ~/Downloads/arch-drive-home
sudo rsync -a --delete --exclude=/lost+found --info=progress2 $mnt_dir/home/ ~/Downloads/arch-drive-home
