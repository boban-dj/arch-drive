#!/bin/bash
. "$(dirname `readlink -f "${BASH_SOURCE[0]}"`)"/common.sh

select-drive

run-script mount $drive_path

HOME=/root chroot-cmd bash
