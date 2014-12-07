#!/bin/bash
. "$(dirname `readlink -f "${BASH_SOURCE[0]}"`)"/common.sh

select-drive
detect-drive-name

declare -A settings=(
  [journaling]=on
  [architecture]=$arch
)

while :; do
  # TODO
  settings_line=`printf ", %s" "${settings[@]}"`
  settings_line=${settings_line:2}

  options=(
    "Selected drive: $drive_name"
    "Settings: $settings_line"
    "Backup home partition"
    "Format drive"
    "Restore home partition"
    "Setup system"
    "Quit"
  )

  echo "Select action:"
  select option in "${options[@]}"; do
    [[ $option == Quit ]] || echo

    case $option in
      "Selected drive:"*)
        select-drive -r
        detect-drive-name
        break
        ;;
      Quit)
        exit
        ;;
    esac
  done
done
