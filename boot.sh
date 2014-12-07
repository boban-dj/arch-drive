#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

do-packages() {
  chroot-cmd pacman -S --needed --noconfirm syslinux
}

do-syslinux-install() {
  chroot-cmd bash `[[ ! $- =~ x ]] || echo -x` syslinux-install_update -im
}

do-syslinux-config() {
  sudo sed -i "s/^\(TIMEOUT\) .*/\1 10/" $mnt_dir/boot/syslinux/syslinux.cfg                                   
  root_uuid=`partition-uuid 2`
  sudo sed -i "s/^\(\s*APPEND root\)=[^ ]*/\1=UUID=$root_uuid/" $mnt_dir/boot/syslinux/syslinux.cfg
}

run-actions
