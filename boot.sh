#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

do-install-packages() {
  chroot-cmd pacman -S --needed --noconfirm syslinux prebootloader gummiboot intel-ucode
}

do-install-syslinux() {
  chroot-cmd bash `[[ ! $- =~ x ]] || echo -x` syslinux-install_update -im
}

do-configure-syslinux() {
  sudo sed -i "s/^\(TIMEOUT\) .*/\1 10/" $mnt_dir/boot/syslinux/syslinux.cfg                                   
  root_uuid=`partition-uuid 2`
  sudo sed -i "s/^\(\s*APPEND root\)=[^ ]*/\1=UUID=$root_uuid/" $mnt_dir/boot/syslinux/syslinux.cfg
  sudo sed -i "s|^\(\s*INITRD\) \(\.\./initramfs-linux\.img\)|\1 ../intel-ucode.img,\2|" $mnt_dir/boot/syslinux/syslinux.cfg
}

do-copy-efi-applications() {
  sudo mkdir -p $mnt_dir/boot/EFI/boot

  sudo cp $mnt_dir/usr/lib/prebootloader/PreLoader.efi $mnt_dir/boot/EFI/boot/bootx64.efi
  sudo cp $mnt_dir/usr/lib/prebootloader/HashTool.efi $mnt_dir/boot/EFI/boot/
  sudo cp $mnt_dir/usr/lib/gummiboot/gummibootx64.efi $mnt_dir/boot/EFI/boot/loader.efi

  sudo curl -o $mnt_dir/boot/EFI/boot/shellx64-v1.efi https://svn.code.sf.net/p/edk2/code/trunk/edk2/EdkShellBinPkg/FullShell/X64/Shell_Full.efi
  sudo curl -o $mnt_dir/boot/EFI/boot/shellx64.efi https://svn.code.sf.net/p/edk2/code/trunk/edk2/ShellBinPkg/UefiShell/X64/Shell.efi

  sudo mkdir -p $mnt_dir/boot/EFI/Microsoft/Boot
  sudo cp $mnt_dir/boot/EFI/boot/bootx64.efi $mnt_dir/boot/EFI/Microsoft/Boot/bootmgfw.efi
}

do-configure-gummiboot() {
  sudo mkdir -p $mnt_dir/boot/loader/entries

  sudo tee $mnt_dir/boot/loader/loader.conf >/dev/null <<EOF
timeout 1
default arch
EOF

  sudo tee $mnt_dir/boot/loader/entries/arch.conf >/dev/null <<EOF
title Arch Linux
linux /vmlinuz-linux
initrd /intel-ucode.img
initrd /initramfs-linux.img
options root=UUID=`partition-uuid 2` rw
EOF
  sudo tee $mnt_dir/boot/loader/entries/arch-fallback.conf >/dev/null <<EOF
title Arch Linux Fallback
linux /vmlinuz-linux
initrd /initramfs-linux-fallback.img
options root=UUID=`partition-uuid 2` rw
EOF
  sudo tee $mnt_dir/boot/loader/entries/uefi-shell-v1.conf >/dev/null <<EOF
title UEFI Shell v1
efi /EFI/boot/shellx64-v1.efi
EOF
  sudo tee $mnt_dir/boot/loader/entries/uefi-shell-v2.conf >/dev/null <<EOF
title UEFI Shell v2
efi /EFI/boot/shellx64.efi
EOF
}

run-actions
