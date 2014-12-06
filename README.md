# Arch Drive

The aim of this project is to provide convenient scripts for performing a regular Arch Linux installation onto any USB drive (flash, HDD, etc). So you could boot lightweight persistent Linux OS from any computer (PC or Mac).

## Requirements for running scripts

- Any USB drive with capacity of 2GB minimum.
- An existing host Linux system. The supported distributions are: Arch Linux, Ubuntu, Debian and derrivatives.
- The Internet connection on a host system.

## How to get a host Linux system?

If you already have installed somewhere one of the supported Linux systems, you could use it and skip this section. Otherwise you have the following options:

### Boot Live Linux from optical media or USB drive

Download any Live Linux image.

- Arch Linux: https://www.archlinux.org/download/
- Ubuntu: http://www.ubuntu.com/download/desktop/
- Debian: http://live.debian.net/cdimage/release/stable+nonfree/

Burn the downloaded .iso file to an optical disk, or create a bootable USB drive from it using appropriate instruction.

- Arch Linux: https://wiki.archlinux.org/index.php/USB\_Flash\_Installation\_Media
- Ubuntu: http://www.ubuntu.com/download/desktop/
- Debian: http://live.debian.net/manual/stable/html/live-manual/the-basics.en.html#181

Boot the system from optical disk or USB drive. Establish an Internet connection on running system.

### Use Vagrant environment

If you are familiar with Vagrant software, you could use it for creating USB drive from any operating system it supports.

To use it, you need to download and install VirtualBox, VirtualBox Oracle VM VirtualBox Extension Pack and Vagrant itself. Note that currently VirtualBox does not support the USB 3.0. In this case you should try to use USB 2.0 port or external hub. Also note that Vagrant box is configured to catch all USB devices during runtime.

This project provides Vagrantfile that describes environment suitable for running scripts. In your terminal you need to `cd` to directory containing Vagrantfile, run `vagrant up`, then `vagrant ssh`. The scripts will be located at `/vagrant`.

## Create Arch Drive with scripts

1. Ensure you are running Linux and have established Internet connection. Note that the installable system will have the same architecture as the host system. So if you would like to create the system with x86 32-bit (or 64-bit) architecture, you should use the host system with x86 32-bit (or 64-bit) one.
2. Download and unpack files from this repository to some place. Or you could clone it from terminal using `git clone git@bitbucket.org:sgtpep/arch-drive.git`.
3. Open the terminal emulator or virtual terminal.
4. Run `cd /path/to/scripts`, where `/path/to/scripts` is the path to a directory that contains downloaded scripts.
5. Insert your USB drive.
7. If it is a first time you are installing Arch Drive on this drive, run `./format.sh` to format it. Note that this action will destroy all data on it, including your home directory partition! If you would like to backup it first, run `./backup.sh`. After formatting your drive with `./format.sh` you could restore the contents of home directory partition by running `./restore.sh`.
8. To install the operating system on formatted drive run `./system.sh`.
9. You can unmount your drive after installation by running `./umount.sh`, or it will be unmounted on next poweroff of the host system.
10. Insert your drive with newly installed system to any powered off computer. Power it on and call the boot menu by pressing a shortcut key that is specific to this computer. It could be Esc, F8, F9, F11, or F12. On Apple Macs it is an Option/Alt key. Select your flash drive from menu and see how it boots up.

If you encounter any problems, feel free to report an [issue](https://bitbucket.org/sgtpep/arch-drive/issues).
