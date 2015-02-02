# Arch Drive

The aim of this project is to provide convenient tool for vanilla Arch Linux installation on any external or internal drive (flash, HDD, etc.), so the system installed on external drive becomes portable and bootable on any computer (PC or Mac).

## End-user features

- Creates full-blown operating system on external or internal drive.
- The system installed on drive boots and runs on potentially any PC and Mac.
- The installation process is interactive using menus and confirmations.
- Allows you to backup existing drive home directory partition content on drive, reformat it, than restore home partition content from backup.
- Detects your country and sets the fastest mirror for package manager.
- Configures autoconnection to wired and wireless networks on installed system.
- Makes tool for interactive connection to WiFi networks (wifi-menu) usable on installed system.

## Technical features

- Filesystem journaling could be disabled during format (might be useful for installation on flash drives).
- Allows to create the system with i686 architecture from system with x86\_64 one.
- Installs Syslinux bootloader on BIOS systems.
- Installs gummiboot bootloader on UEFI systems.
- Installs pre-bootloader for compatibility with Secure Boot.
- The tool consists of hackable scripts, which could be used separately.
- The Vagrantfile is provided for using the tool on any platform.

## Screenshot

![Screenshot](screenshot.png?raw=true)

## Requirements for running the tool

- Any target drive with capacity of 2GB minimum.
- An existing host Linux system. The supported distributions are: Arch Linux, Ubuntu, Debian and derrivatives.
- The Internet connection on a host system.

## How to get a host Linux system?

If you already have installed one of the supported Linux systems somewhere, you could use it and skip this section. See other options below.

### Boot Live Linux from optical media or external USB drive

Download any Live image of the supported Linux systems: [Arch Linux](https://www.archlinux.org/download/), [Ubuntu](http://www.ubuntu.com/download/desktop/), [Debian](http://live.debian.net/cdimage/release/stable+nonfree/). Burn the downloaded .iso file to an optical disk, or create a bootable USB drive from it using appropriate instruction: [Arch Linux](https://wiki.archlinux.org/index.php/USB_Flash_Installation_Media), [Ubuntu](http://www.ubuntu.com/download/desktop/), [Debian](http://live.debian.net/manual/stable/html/live-manual/the-basics.en.html#181). Boot the system from optical disk or USB drive. Establish an Internet connection on running Live system.

### Use Vagrant environment

If you are familiar with Vagrant, you could use this tool from any operating system it supports. This repository provides the Vagrantfile that describes environment configured for running this tool.

To use it, you need to download and install VirtualBox, VirtualBox Oracle VM VirtualBox Extension Pack and Vagrant itself. Please note that VirtualBox does not have support for USB 3.0 currently, you could connect your USB 3.0 drive to USB 2.0 port or external hub. Also note that provided Vagrant environment is configured to grab all newly connected USB devices during runtime.

## Create Arch Drive

1. Ensure you are running Linux and have established Internet connection.
2. Open the terminal emulator or switch to virtual terminal.
3. Connect an external drive to computer, if you wish to install the system on it.
4. Run `bash <(curl https://raw.githubusercontent.com/sgtpep/arch-drive/master/run.sh)`. If it fails with `No command 'curl' found`, try to run `bash <(wget -O - https://raw.githubusercontent.com/sgtpep/arch-drive/master/run.sh)`. Of course, you could also download this tool manually or clone this repository, and then run `./run.sh` from directory with tool files.
5. Select target drive from menu. You can select another target drive later using menu option *1) Change target drive*.
6. Menu option *2) Change settings* opens the submenu that allows you to change following system settings:
    1. *1) Filesystem journaling* allows you to turn filesystem journaling off during formatting. It could prolong the life of flash drive memory (if you are installing on it) and improve the writing speed at the cost of the risk increase of losing some data on abnormal poweroffs.
    2. *2) Target architecture* allows you to change the target system architecture on host system with x86\_64 architectures from x86\_64 to i686, if needed.
7. If it is a first time you are installing the system on this drive or you would like to reinstall it from scratch, select *3) Format drive*. It will open the submenu with following options:
    1. *1) Backup home partition* performs a backup of existing home directory partition content on target drive to `~/Downloads/arch-drive-home` directory.
    2. *2) Format drive* performs the format process on currently selected drive. Please note that this action will destroy all data on it, including its home directory partition!
    3. *3) Restore home partition* allows you to restore the content of home directory partition from previously saved backup in `~/Downloads/arch-drive-home` directory.
8. To setup Arch Linux on properly formatted drive select *4) Setup system*.
9. Select *5) Quit* to unmount the drive and quit from tool.
10. To try to boot the installed system ensure the drive is connected to computer. Reboot it or power it on, and call the boot menu by pressing a shortcut key that is specific to this particular computer. It could be Esc, F8, F9, F11, or F12. On Apple Macs it is Option/Alt key. Select your drive item from menu and see how its system boots up.

If you encounter any problems, feel free to report an [issue](https://github.com/sgtpep/arch-drive/issues).

## Caveats

- The systems installed with i686 architecture will not boot in UEFI mode. The systems installed with x86\_64 architecture will not boot in UEFI mode on rare PCs and pre-2008 Macs with 32-bit UEFI firmwares. In both cases you have the following options. On PCs you could try to boot in legacy mode (BIOS-compatibility mode). On older Macs you could use the [rEFInd](http://www.rodsbooks.com/refind/) boot manager.
- The installed system will not have swap partition for prolonging the life of flash drive memory. This means that the system memory usage will be limited by your phisical RAM size. If you have installed the system to a hard drive, you could create and activate [swap file](https://wiki.archlinux.org/index.php/Swap#Swap_file). Also you could create the swap in RAM using [zram](https://wiki.archlinux.org/index.php/maximizing_performance#Compcache.2FZram_or_zswap) or [zswap](https://wiki.archlinux.org/index.php/Zswap).

## FAQ

#### What is the default user/password on installed system?

The only user on system is root without a password. You could change the password by running `passwd`. Or you could create regular user, install sudo package, add created user to sudoers and lock root user by running `passwd -l root`. 

#### How to connect to the network on installed system?

Run command `ip link` to show the available network interfaces. If you see eth0, you could connect Ethernet cable to your computer and wait few seconds until connection will be autoconfigured. If you see wlan0, your computer has compatible WiFi adapter, and you could connect to any WiFi network by running `wifi-menu`.

#### How to make external drive the default boot option on Mac?

Boot to OS X and open Terminal. Run `diskutil list`. Notice the disk number of your USB drive. Run `sudo bless --setBoot --device=/dev/disk1s1`, where `disk1` contains the correct number of your USB drive. Also you could install [rEFInd](http://www.rodsbooks.com/refind/) and configure boot priorities with it.

### How to encrypt data on my drive?

The easiest option to encrypt some data or whole home directory is to use [eCryptfs](https://wiki.archlinux.org/index.php/ECryptfs). There are other options for [disk encryption](https://wiki.archlinux.org/index.php/Disk_encryption). Please note that full disk encryption requires different partition scheme, which this tool does not yet support.

## License and copyright

The project is released under the General Public License (GPL), version 3.

Copyright © 2014, Danil Semelenov.
