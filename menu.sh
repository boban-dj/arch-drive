#!/bin/bash
. "`dirname "${BASH_SOURCE[0]}"`"/common.sh

select-drive
detect-drive-name

declare -A settings=(
  [1-journaling]=on
  [2-architecture]=$arch
)

select-settings() {
  while :; do
    local options=()
    for setting_name in "${!settings[@]}"; do
      [[ $setting_name != 2-architecture || $arch == x86_64 ]] || continue

      option_setting_name=${setting_name#[0-9]-}
      options+=("${option_setting_name^}: ${settings[$setting_name]}")
    done
    options+=(Back)

    select-title "Select an option to change:"
    select option in "${options[@]}"; do
      case $option in
        Journaling:*)
          settings[1-journaling]=`[[ ${settings[1-journaling]} == off ]] && echo on || echo off`
          ;;

        Architecture:*)
          settings[2-architecture]=`[[ ${settings[2-architecture]} == x86_64 ]] && echo i686 || echo x86_64`
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
  settings_text=()
  for setting_name in "${!settings[@]}"; do
    settings_text+=("${setting_name#[0-9]-}: ${settings[$setting_name]}")
  done
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
      "Selected drive:"*)
        select-drive -r
        detect-drive-name
        ;;

      Settings:*)
        select-settings
        ;;

      "Backup home partition")
        echo
        run-script backup $drive_path
        ;;

      "Format drive")
        echo
        run-script format $drive_path ${settings[1-journaling]}
        ;;
      
      "Setup base system")
        echo
        run-script system $drive_path ${settings[2-architecture]}
        ;;

      "Restore home partition")
        echo
        run-script restore $drive_path
        ;;

      Quit)
        run-script umount $drive_path
        exit
        ;;
    esac

    break
  done
done
