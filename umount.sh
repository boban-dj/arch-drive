#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive -q

if [[ -n ${drive_path:-} ]]; then
  mount_paths=(`grep -oP "^$drive_path[p0-9](?= .+)" /etc/mtab | tac || :`)
  [[ -z ${mount_paths:-} ]] || sudo umount "${mount_paths[@]}"
fi

mount_paths=(`grep "^[^ ]* $mnt_dir[ /]" /etc/mtab | cut -d ' ' -f 2 | tac || :`)
[[ -z ${mount_paths:-} ]] || sudo umount ${mount_paths[@]}
