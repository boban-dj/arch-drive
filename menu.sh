#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive
detect-drive-name

declare -A settings=(
  [journaling]=on
  [architecture]=$arch
)

select-settings() {
  while :; do
    options=("Filesystem journaling: ${settings[journaling]}")
    [[ $arch != x86_64 ]] || options+=("Target architecture: ${settings[architecture]}")
    options+=(Back)

    select-title "Select an option to change:"
    select option in "${options[@]}"; do
      case $option in
        "Filesystem journaling:"*)
          settings[journaling]=`[[ ${settings[journaling]} == off ]] && echo on || echo off`
          ;;

        "Target architecture:"*)
          settings[architecture]=`[[ ${settings[architecture]} == x86_64 ]] && echo i686 || echo x86_64`
          ;;

        Back)
          return
          ;;
      esac

      break
    done
  done
}

while :; do
  settings_text=(
    "journaling: ${settings[journaling]}"
    "architecture: ${settings[architecture]}"
  )
  settings_text=`printf ", %s" "${settings_text[@]}"`
  settings_text=${settings_text#, }

  options=(
    "Change target drive: $drive_name"
    "Change settings: $settings_text"
    "Backup home partition"
    "Format drive"
    "Restore home partition"
    "Setup base system"
    Quit
  )

  select-title "Select an action:"
  select option in "${options[@]}"; do
    case $option in
      "Change target drive:"*)
        select-drive -r
        detect-drive-name
        ;;

      "Change settings:"*)
        select-settings
        ;;

      "Backup home partition")
        echo
        run-script backup $drive_path
        ;;

      "Format drive")
        echo
        run-script format $drive_path ${settings[journaling]}
        ;;
      
      "Restore home partition")
        echo
        run-script restore $drive_path
        ;;

      "Setup base system")
        echo
        run-script system $drive_path ${settings[architecture]}
        ;;

      Quit)
        run-script umount $drive_path
        exit
        ;;
    esac

    break
  done
done
