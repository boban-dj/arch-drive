#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

run-script mount $drive_path

if [[ ! `find $mnt_dir/home -maxdepth 1 -! -name lost+found | sed 1d` ]]; then
  echo "Home partition is empty."
  exit
fi

backup_dir=~/Downloads/arch-drive-home
mkdir -p $backup_dir

[[ ! -f /home/.rsync-excludes ]] || rsync_args="--exclude-from=/home/.rsync-excludes"
sudo rsync -a ${rsync_args:-} --delete --info=progress2 $mnt_dir/home/ $backup_dir

echo "Backup was saved to ${backup_dir/#$HOME/\~}."
