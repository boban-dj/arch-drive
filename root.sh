#!/bin/bash
. "$(dirname `readlink -f "${BASH_SOURCE[0]}"`)"/common.sh

select-drive

target_arch=${2:-$arch}
bootstrap_path=/tmp/arch-drive/downloads/bootstrap-$target_arch.tar.gz

mirror-url() {
  local country_code=`curl ipinfo.io/country`
  curl "https://www.archlinux.org/mirrorlist/?country=$country_code&use_mirror_status=on" | grep -oP -m 1 "(?<=^#Server = )http.+?(?=/\\$)"
}

do-bootstrap-download() {
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

  mkdir -p /tmp/arch-drive/downloads
  curl -v -o $bootstrap_path $iso_url/$bootstrap_filename
  bootstrap-check-md5
}

do-bootstrap-unpack() {
  sudo tar -vxz -f $bootstrap_path -C $mnt_dir --exclude=README --strip-components=1
}

do-locale() {
  locale=en_US.UTF-8                                                                                       
  sudo sed -i "0,/^[#]\(${locale//./\\.}\)/s//\1/" $mnt_dir/etc/locale.gen
  LC_ALL= chroot-cmd locale-gen

  echo LANG=$locale | sudo tee $mnt_dir/etc/locale.conf >/dev/null
}

do-pacman-key() {
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

do-mirror-list() {
  update-mirror-list
}

do-upgrade() {
  chroot-cmd pacman -Syu --noconfirm

  if [[ -f $mnt_dir/etc/pacman.d/mirrorlist.pacnew ]]; then
    sudo mv $mnt_dir/etc/pacman.d/mirrorlist{.pacnew,}
    update-mirror-list
  fi
}

do-fstab() {
  boot_uuid=`partition-uuid 1` root_uuid=`partition-uuid 2` home_uuid=`partition-uuid 3`
  sudo tee $mnt_dir/etc/fstab >/dev/null <<EOF
UUID=$boot_uuid /boot vfat defaults 0 2
UUID=$root_uuid / ext4 defaults 0 1
UUID=$home_uuid /home ext4 defaults 0 2
EOF
}

do-packages() {
  chroot-cmd pacman -S --needed --noconfirm base
}

run-actions
