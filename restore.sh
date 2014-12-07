#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

run-script mount $drive_path

if [[ ! -d ~/Downloads/arch-drive-home ]]; then
  echo "No home partition backup was found."
  exit
fi

read -p "Restore home partition content from backup? All existing home partition content will be replaced by content from backup! [y/N] "
[[ $REPLY =~ ^[Yy] ]] || exit 0

sudo rsync -a --delete --exclude=/lost+found --info=progress2 ~/Downloads/arch-drive-home/ $mnt_dir/home
