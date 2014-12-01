#!/bin/bash
. ${BASH_SOURCE[0]%/*}/common.sh

select-drive

01-syslinux-install() {
  chroot-bash <<EOF
  pacman -S --noconfirm syslinux

  syslinux-install_update -im
EOF
}

02-syslinux-config() {
  sudo sed -i "s/^\(TIMEOUT\) .*/\1 10/" $mnt_dir/boot/syslinux/syslinux.cfg                                   
  root_uuid=`partition-uuid 2`
  sudo sed -i "s/^\(\s*APPEND root\)=[^ ]*/\1=UUID=$root_uuid/" $mnt_dir/boot/syslinux/syslinux.cfg
}

run-actions
