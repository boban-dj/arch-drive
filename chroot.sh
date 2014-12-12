#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

run-script mount $drive_path

shift 1
HOME=/root chroot-cmd "${@:-bash}"
