#!/bin/bash
. ${BASH_SOURCE[0]%/*}/common.sh

select-drive

mirror-url() {
  local country_code=`curl ipinfo.io/country`
  curl "https://www.archlinux.org/mirrorlist/?country=$country_code&use_mirror_status=on" | grep -oP -m 1 "(?<=^#Server = )http.+?(?=/\\$)"
}

01-bootstrap() {
  if [[ ! -f /tmp/arch-drive/downloads/bootstrap.tar.gz ]]; then
    iso_url=`mirror-url`/iso/latest
    bootstrap_filename=`curl $iso_url/ | grep -oP "(?<= href=\")archlinux-bootstrap-[^-]+-$architecture.tar.gz(?=\")"`
    bootstrap_md5=`curl $iso_url/md5sums.txt | grep -oP "^[^\s]+(?=\s+$bootstrap_filename$)"`

    mkdir -p /tmp/arch-drive/downloads
    [[ -f /tmp/arch-drive/downloads/$bootstrap_filename ]] || curl -o /tmp/arch-drive/downloads/$bootstrap_filename $iso_url/$bootstrap_filename || :
    if ! echo "$bootstrap_md5 /tmp/arch-drive/downloads/$bootstrap_filename" | md5sum -c; then
      rm /tmp/arch-drive/downloads/$bootstrap_filename
      exit 1
    fi
  fi

  sudo tar -vxz -f /tmp/arch-drive/downloads/$bootstrap_filename -C $mnt_dir --exclude=README --strip-components=1
}

02-locale() {
  locale=en_US.UTF-8                                                                                       
  sudo sed -i "0,/^[#]\(${locale//./\\.}\)/s//\1/" $mnt_dir/etc/locale.gen
  LC_ALL= chroot-cmd locale-gen

  echo LANG=$locale | sudo tee $mnt_dir/etc/locale.conf >/dev/null
}

03-pacman-key() {
  if ! pgrep -x haveged >/dev/null; then
    sudo haveged -F &
    haveged_pid=$!
    trap "sudo kill $haveged_pid" INT TERM EXIT
  fi

  chroot-bash <<EOF
  pacman-key --init
  pacman-key --populate archlinux

  for proc_path in /proc/[0-9]*; do
    if [[ \`cat \$proc_path/cmdline\` == gpg-agent* ]]; then
      kill \${proc_path#/proc/}
      break
    fi
  done
EOF
}

update-mirror-list() {
  local mirror_url=`mirror-url`
  sudo sed -i "s|^#\(Server = ${mirror_url//./\\.}/\)|\1|" $mnt_dir/etc/pacman.d/mirrorlist
}

04-mirror-list() {
  update-mirror-list
}

05-upgrade() {
  chroot-cmd pacman -Syu --noconfirm

  if [[ -f $mnt_dir/etc/pacman.d/mirrorlist.pacnew ]]; then
    sudo mv $mnt_dir/etc/pacman.d/mirrorlist{.pacnew,}
    update-mirror-list
  fi
}

06-fstab() {
  boot_uuid=`partition-uuid 1` root_uuid=`partition-uuid 2` home_uuid=`partition-uuid 3`
  sudo tee $mnt_dir/etc/fstab >/dev/null <<EOF
UUID=$boot_uuid /boot vfat defaults 0 2
UUID=$root_uuid / ext4 defaults 0 1
UUID=$home_uuid /home ext4 defaults 0 2
EOF
}

07-packages() {
  packages=(base)
  chroot-cmd pacman -S --needed --noconfirm ${packages[@]}
}

run-actions
