#!/bin/bash
. ${BASH_SOURCE[0]%/*}/common.sh

select-drive

mount_paths=(`cat /etc/mtab | grep -oP "^$drive_path[p0-9](?= .+)" | tac || :`)
[[ -z ${mount_paths:-} ]] || sudo umount ${mount_paths[@]}

mount_paths=(`cat /etc/mtab | grep "^[^ ]* $mnt_dir[ /]" | cut -d ' ' -f 2 | tac || :`)
[[ -z ${mount_paths:-} ]] || sudo umount ${mount_paths[@]}
