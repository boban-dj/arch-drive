#!/bin/bash
. "$(dirname `readlink -f "${BASH_SOURCE[0]}"`)"/common.sh

select-drive

01-packages() {
  chroot-cmd pacman -S --needed --noconfirm syslinux
}

02-syslinux-install() {
  chroot-cmd bash `[[ ! $- =~ x ]] || echo -x` syslinux-install_update -im
}

03-syslinux-config() {
  sudo sed -i "s/^\(TIMEOUT\) .*/\1 10/" $mnt_dir/boot/syslinux/syslinux.cfg                                   
  root_uuid=`partition-uuid 2`
  sudo sed -i "s/^\(\s*APPEND root\)=[^ ]*/\1=UUID=$root_uuid/" $mnt_dir/boot/syslinux/syslinux.cfg
}

run-actions
