#!/bin/bash
set -eu -o pipefail
IFS=$'\n'

args=($@)
arch=`uname -m`
script_dir=$(dirname `readlink -f "${BASH_SOURCE[0]}"`)
mnt_dir=/tmp/arch-drive/mnt

on-error() {
  local status=$?
  trap - INT ERR EXIT
  [[ $status == 0 ]] || echo -e "\e[4mError code: $status\e[m" >&2
  exit $status
}
trap on-error INT ERR EXIT

fatal-error() {
  echo $1 >&2
  exit 1
}

[[ $OSTYPE == linux-gnu ]] || fatal-error "This script is intended to be run on Linux."
[[ $arch =~ ^i[0-9]86|x86_64$ ]] || fatal-error "This script is intended to be run on x86 32-bit or 64-bit architectures."

install-packages() {
  declare -A packages=(
    [parted]=parted
    [mkfs.fat]=dosfstools
    [rsync]=rsync
    [curl]=curl
    [objdump]=binutils
    [haveged]=haveged
  )

  if ! which ${!packages[@]} >/dev/null; then
    if which apt-get dpkg >/dev/null; then
      read -p "Install required packages? (`echo ${packages[@]}`) [Y/n] "
      [[ $REPLY =~ ^[Yy]*$ ]] && sudo apt-get install -y ${packages[@]} || exit 1
      echo
    elif which pacman >/dev/null; then
      sudo pacman -S --needed ${packages[@]}
      echo
    else
      fatal-error "Please install following packages: ${packages[@]}."
    fi
  fi
}
install-packages

run-script() {
  local script_name=$1
  shift
  bash -$- "$script_dir"/$script_name.sh $@
}

drive-name-parse() {
  grep "^Model: \|^Disk /" | sed "/^Model: .*/N;s|^Model: \(.*\) (.*)\nDisk \(/.*\): \(.*\)|\1 (\3) \2|"
}

mounted-drive-path() {
  local mounted_partition_path=`cat /etc/mtab | grep "^[^ ]* $1 " | cut -d ' ' -f 1 || :`
  echo $mounted_partition_path | sed "s/p\?[0-9]$//"
}

select-drive() {
  if [[ -n ${args[0]:-} ]]; then
    drive_path=${args[0]}
    return
  fi

  local host_drive_path=`mounted-drive-path /`
  local drive_names=(`sudo parted -ls | drive-name-parse | grep -v ") $host_drive_path$"`)
  if [[ -z ${drive_names:-} ]]; then
    [[ ${1:-} != -q ]] || return 0
    fatal-error "No drives were found."
  fi

  echo "Select a target drive:"
  select drive_name in "${drive_names[@]}"; do
    [[ -z $drive_name ]] || break
  done

  drive_path=${drive_name##*) }
  unset drive_name
}

drive-name() {
  sudo parted -s $drive_path print 2>/dev/null | drive-name-parse || :
}

partition-path() {
  echo -n $drive_path
  [[ $drive_path != *[0-9] ]] || echo -n p
  echo $1
}

partition-uuid() {
  local partition_path=`partition-path $1`
  sudo blkid -o value -s UUID $partition_path
}

run-actions() {
  local script_name=${BASH_SOURCE[1]##*/}
  local result_dir=$mnt_dir/var/lib/arch-drive/${script_name%.*}
  sudo mkdir -p $result_dir

  local action_names=(`cat "${BASH_SOURCE[1]}" | grep -oP "(?<=^do-).+?(?=\(\))"`)
  for action_name in ${action_names[@]}; do
    [[ ! -f $result_dir/$action_name ]] || continue

    do-$action_name
    sudo touch $result_dir/$action_name
  done
}

chroot-cmd() {
  [[ $arch =~ ^i[0-9]86$ ]] || objdump -f $mnt_dir/bin/chroot | grep -q "\-x86-64" || local linux_cmd=linux32
  sudo ${linux_cmd:-} $mnt_dir/bin/arch-chroot $mnt_dir "$@"
}

chroot-bash() {
  chroot-cmd bash -$-
}
