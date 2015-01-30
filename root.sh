#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive

target_arch=${2:-$arch}
bootstrap_path=/tmp/arch-drive/downloads/bootstrap-$target_arch.tar.gz

mirror-url() {
  if [[ ${mirror_url:-} ]]; then
    echo $mirror_url
    return
  fi

  for _ in {1..3}; do
    local country_code=`curl -f http://www.geoiptool.com/ | tr -d -c "[:print:]\n" | grep -m 1 -A 1 "Country Code:" | grep -oP "(?<=<span>).+(?= \()" || :`
    [[ ! $country_code ]] || break
  done

  if [[ ! $country_code ]]; then
    echo "Unable to detect the country, fallback to US." >&2
    local country_code=US
  fi

  mirror_url=`curl "https://www.archlinux.org/mirrorlist/?country=$country_code&use_mirror_status=on" | grep -oP -m 1 "(?<=^#Server = )http.+?(?=/\\\\$)"`
  echo $mirror_url
}

do-download-bootstrap() {
  iso_url=`mirror-url`/iso/latest
  bootstrap_filename=`curl $iso_url/ | grep -oP "(?<= href=\")archlinux-bootstrap-[^-]+-$target_arch.tar.gz(?=\")"`
  bootstrap_md5=`curl $iso_url/md5sums.txt | grep -oP "^[^\s]+(?=\s+$bootstrap_filename$)"`

  bootstrap-check-md5() {
    [[ -f $bootstrap_path ]] || return 0

    if ! echo "$bootstrap_md5 $bootstrap_path" | md5sum -c; then
      rm $bootstrap_path
      return 1
    fi
  }
  bootstrap-check-md5 || :

  if [[ ! -f $bootstrap_path ]]; then
    mkdir -p /tmp/arch-drive/downloads
    curl -\# -o $bootstrap_path $iso_url/$bootstrap_filename
    bootstrap-check-md5
  fi
}

do-unpack-bootstrap() {
  sudo tar -vxz -f $bootstrap_path -C $mnt_dir --exclude=README --strip-components=1
}

do-setup-pacman-keys() {
  if ! pgrep -x haveged >/dev/null; then
    sudo haveged -F &
    haveged_pid=$!
    trap "sudo kill $haveged_pid" INT TERM EXIT
  fi

  chroot-bash <<EOF
  pacman-key --init
  pacman-key --populate archlinux
EOF
}

update-mirror-list() {
  local mirror_url=`mirror-url`
  sudo sed -i "s|^#\(Server = ${mirror_url//./\\.}/\)|\1|" $mnt_dir/etc/pacman.d/mirrorlist
}

do-update-mirror-list() {
  update-mirror-list
}

do-upgrade-packages() {
  chroot-cmd pacman -Syu --noconfirm

  if [[ -f $mnt_dir/etc/pacman.d/mirrorlist.pacnew ]]; then
    sudo mv $mnt_dir/etc/pacman.d/mirrorlist{.pacnew,}
    update-mirror-list
  fi
}

do-configure-fstab() {
  boot_uuid=`partition-uuid 1` root_uuid=`partition-uuid 2` home_uuid=`partition-uuid 3`
  sudo tee $mnt_dir/etc/fstab >/dev/null <<EOF
UUID=$boot_uuid /boot vfat defaults 0 0
UUID=$root_uuid / ext4 defaults 0 1
UUID=$home_uuid /home ext4 defaults 0 2
EOF
}

do-install-packages() {
  packages=(
    base
    ifplugd wpa_{supplicant,actiond} dialog
    bash-completion
  )

  chroot-cmd pacman -S --needed --noconfirm ${packages[@]}
}

do-configure-locale() {
  locale=en_US.UTF-8
  sudo sed -i "0,/^[#]\(${locale//./\\.}\)/s//\1/" $mnt_dir/etc/locale.gen
  chroot-cmd locale-gen

  echo LANG=$locale | sudo tee $mnt_dir/etc/locale.conf >/dev/null
}

do-make-initramfs() {
  mkinitcpio_hooks=(
    base
    udev
    modconf
    block
    filesystems
    keyboard
    fsck
  )

  sudo sed -i "s/^\(HOOKS\)=.*/\1=\"`echo ${mkinitcpio_hooks[@]}`\"/" $mnt_dir/etc/mkinitcpio.conf

  chroot-cmd mkinitcpio -p linux
}

do-configure-network() {
  sudo ln -fs /dev/null $mnt_dir/etc/udev/rules.d/80-net-setup-link.rules

  sudo ln -fs /usr/lib/systemd/system/dhcpcd@.service $mnt_dir/etc/systemd/system/multi-user.target.wants/dhcpcd@eth0.service
  sudo ln -fs /usr/lib/systemd/system/netctl-ifplugd@.service $mnt_dir/etc/systemd/system/multi-user.target.wants/netctl-ifplugd@eth0.service
  sudo ln -fs /usr/lib/systemd/system/netctl-auto@.service $mnt_dir/etc/systemd/system/multi-user.target.wants/netctl-auto@wlan0.service
}

run-actions
