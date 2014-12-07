# Arch Drive

The aim of this project is to provide the convenient tool for vanilla Arch Linux installation to any USB drive (flash, HDD, etc.), which could be booted from any computer (PC or Mac) and have network access.

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

To use it, you need to download and install VirtualBox, VirtualBox Oracle VM VirtualBox Extension Pack and Vagrant itself. Please note that VirtualBox does not have support for USB 3.0 currently. In that case you could try to connect your drive using USB 2.0 port or external hub. Also note that provided Vagrant environment is configured to catch all host USB devices during runtime.

## Create Arch Drive with scripts

1. Ensure you are running Linux and have established Internet connection.
2. Open the terminal emulator or virtual terminal.
3. Insert any USB drive.
4. Run `bash <(curl https://bitbucket.org/sgtpep/arch-drive/raw/master/run.sh)`, if your system has `curl` installed. Or run `bash <(wget -O - https://bitbucket.org/sgtpep/arch-drive/raw/master/run.sh)`, if your system has `wget` installed. Of course, you also could manually download or clone this repository and run `./run.sh` from its directory.
5. Select your drive from menu. You can select another drive later using menu option *1) Change target drive*.
6. You could change some system creation settings using menu option *2) Change settings*.
    1. Journaling could be disabled during formatting. It will reduce wearing of flash drive memory and speed up the writing to it at the cost of the risk to lose some data on unexpected poweroff.
    2. If you are running on x86\_64 architecture, you could change the target system architecture to be x86\_64 or i686.
7. If it is a first time you are installing the system on this drive, select *4) Format drive* to format it. Please note that this action will destroy all data on this drive, including your home directory partition! If you would like to backup it first, select *3) Backup home partition*. After formatting has finished, you could restore the contents of your home directory partition using option *5) Restore home partition*.
8. To setup the operating system on formatted drive select *6) Setup system*.
9. Select *7) Quit* for unmounting the drive and quitting the menu.
10. Insert your drive with newly installed system to any computer. Power it on (or reboot) and call the boot menu by pressing a shortcut key that is specific to this computer. It could be Esc, F8, F9, F11, or F12. On Apple Macs it is Option/Alt key. Select your flash drive from menu and see how it boots up.

If you encounter any problems, feel free to report an [issue](https://bitbucket.org/sgtpep/arch-drive/issues).
