#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

run-script mount $drive_path

backup_dir=~/Downloads/arch-drive-home
echo "Restoring from ${backup_dir/#$HOME/\~}."

if [[ ! -d $backup_dir ]]; then
  echo "No home partition backup directory was found." >&2
  exit
fi

if [[ `find $mnt_dir/home -maxdepth 1 -! -name lost+found | sed 1d` ]]; then
  read -p "Restore home partition content from backup? All existing home partition content will be replaced by content from backup! [y/N] "
  [[ $REPLY =~ ^[Yy] ]] || exit 0
fi

sudo rsync -a --delete --exclude=/lost+found --info=progress2 $backup_dir/ $mnt_dir/home
