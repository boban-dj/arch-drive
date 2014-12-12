# Arch Drive

The aim of this project is to provide convenient tool for vanilla Arch Linux installation to any USB drive (flash, HDD, etc.), which could be booted from any computer (PC or Mac) for further installation and usage.

## End-user features

- Creates full-blown operating system on your USB drive.
- The system installed to drive boots and runs on potentially any PC and Mac.
- The usage is interactive with the help of menus and confirmations.
- Allows you to drive backup home directory partition content, reformat drive, than restore home from backup.
- Detects your country and uncomments the fastest in pacman's mirrorlist.
- Enables autoconnection to wired and wireless networks.
- Includes wifi-menu tool for interactive connection to WiFi networks.

## Technical features

- Filesystem journaling could be disabled during format.
- Allows to create the system with i686 architecture from system with x86\_64 one.
- Uses Syslinux bootloader for booting from BIOS systems
- Uses gummiboot bootloader for booting from UEFI systems.
- The pre-bootloader is installed for booting on systems with Secure Boot.
- The code is separated to scripts, which could be used directly.
- The Vagrantfile is provided for cross-platform usage.

## Requirements for running the tool

- Any USB drive with capacity of 2GB minimum.
- An existing host Linux system. The supported distributions are: Arch Linux, Ubuntu, Debian and derrivatives.
- The Internet connection on a host system.

## How to get a host Linux system?

If you already have installed one of the supported Linux systems somewhere, you could use it and skip this section. Otherwise there are options listed below.

### Boot Live Linux from optical media or USB drive

Download any Live image of the supported Linux systems.

- Arch Linux: https://www.archlinux.org/download/
- Ubuntu: http://www.ubuntu.com/download/desktop/
- Debian: http://live.debian.net/cdimage/release/stable+nonfree/

Burn the downloaded .iso file to an optical disk, or create a bootable USB drive from it using appropriate instructions:

- Arch Linux: https://wiki.archlinux.org/index.php/USB\_Flash\_Installation\_Media
- Ubuntu: http://www.ubuntu.com/download/desktop/
- Debian: http://live.debian.net/manual/stable/html/live-manual/the-basics.en.html#181

Boot the system from optical disk or USB drive. Establish an Internet connection on it.

### Use Vagrant environment

If you are familiar with Vagrant software, you could use it for creating USB drive from any operating system it supports. This repository provides the Vagrantfile that describes environment that is suitable for running this tool.

To use it, you need to download and install VirtualBox, VirtualBox Oracle VM VirtualBox Extension Pack and Vagrant itself. Please note that VirtualBox does not have support for USB 3.0 currently. In that case you could try to connect your drive using USB 2.0 port or external hub. Also note that provided Vagrant environment is configured to grab all newly connected USB devices during runtime.

## Create Arch Drive

1. Ensure you are running Linux and have established Internet connection.
2. Open the terminal emulator or virtual terminal.
3. Insert your USB drive.
4. Run `bash <(curl https://bitbucket.org/sgtpep/arch-drive/raw/master/run.sh)`. If it fails with `No command 'curl' found` than try to run `bash <(wget -O - https://bitbucket.org/sgtpep/arch-drive/raw/master/run.sh)`. Of course, you could also download manually or clone this repository and run `./run.sh` from its directory.
5. Select your drive from menu. You can select another drive later using menu option *1) Change target drive*.
6. Menu option *2) Change settings* opens the submenu that allow you to change following system settings:
    1. *1) Filesystem journaling* allows you to turn filesystem journaling off during formatting. It could reduce the wearing of flash drive memory and improve the writing speed at the cost of the risk increase of losing some data on abnormal poweroff.
    2. *2) Target architecture* allows you to change the target system architecture on host systems with x86\_64 architectures from x86\_64 to i686, if needed.
7. If it is a first time you are installing the system on this drive or you would like to restart from scratch, select *3) Format drive*. It will open the submenu with following actions:
    1. *1) Backup home partition* performs a backup of existing home directory partition content to `~/Downloads/arch-drive-home` directory.
    2. *2) Format drive* performs the format process. Please note that this action will destroy all data on this drive, including your home directory partition!
    3. *3) Restore home partition* allows you to restore the content of home directory partition from previously created backup in `~/Downloads/arch-drive-home` directory.
8. To setup Arch Linux on properly formatted drive select *4) Setup base system*.
9. Select *5) Quit* to unmount the drive and quit from menu.
10. Insert your drive with newly installed system to any computer. Power it on or reboot and call the boot menu by pressing a shortcut key that is specific to this particular computer. It could be Esc, F8, F9, F11, or F12. On Apple Macs it is Option/Alt key. Select your flash drive item from menu and see how its system boots up.

If you encounter any problems, feel free to report an [issue](https://bitbucket.org/sgtpep/arch-drive/issues).

## FAQ

#### What is the default user/password on created system?

The only user on system is root without a password. You could change it by running `passwd`, or create regular user, add it to sudoers and lock root user later with `passwd -l root`. 

#### How to connect to network on created system?

Run command `ip link` to show the available network interfaces. If you see eth0, you could connect Ethernet cable to your computer and wait few seconds until connection will be autoconfigured. If you see wlan0, your computer has compatible WiFi adapter, and you could connect to any WiFi network by running `wifi-menu`.

#### How to make USB drive the default boot option on Mac?

Boot to OS X and open Terminal. Run `diskutil list`. Notice the disk number of your USB drive. Run `sudo bless --setBoot --device=/dev/disk1s1`, where `disk1` contains the correct number of your USB drive.

## License and copyright

The project is released under the General Public License (GPL), version 3.

Copyright © 2014, Danil Semelenov.
