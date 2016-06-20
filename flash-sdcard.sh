#!/bin/sh
# flash-sdcard.sh
#
# Automated Arch Linux ARM install script
# This script installs the latest version of Arch Linux ARM to an SD card.
#
# Based on official installation recommendations: 
#   https://archlinuxarm.org/platforms/armv6/raspberry-pi#installation
#
# This script requires the following input:
#   1. The full path to a block device where Arch ARM is to be installed.
#
# This script performs the following actions:
#   1. Creates 100MB vfat (boot) partition on specified block device;
#   2. Creates ext4 (root) parition on remaining space;
#   3. Creates a temporary directory for mount points and download;
#   4. Downloads a tarball of the lastest ArchARM distribution;
#   5. Extracts files to new root partition;
#   6. Moves /boot directory to boot partiton.
#
# Usage: 
#   bash flash-sdcard.sh /dev/sdcard
# 

## Set flags
set -u
#set -e    # fdisk may throw error codes even on successful writes.

## Check if input value was given and exists.
## Show usage message if not.
if [ $# -ne 1 ] || [ ! -e $1 ]; then
    echo
    echo "Valid path to SD card device is a required argument."
    echo
    echo "Example:"
    echo "   bash $0 /dev/mmcblk0"
    echo
    exit 1
fi

## Wipe SD card.
#dd if=/dev/zero of=$1

## Create partitions using fdisk by simulating user input.
## (fdisk was not designed with non-interactive use in mind.)
echo "o
n
p
1

+100M
n
p
2
 
 
p
w
q
" | fdisk $1

## Sync changes and update partition table.
sync; partprobe $1; sync

## Create tempory directory for mounts and download.
cd `mktemp -d`
mkdir boot root

## If partition numbering for the device follows sda -> sda1 format.
if [ -e "$1"1 ]; then
  mkfs.vfat "$1"1
  mount "$1"1 boot
  mkfs.ext4 "$1"2
  mount "$1"2 root

## If partition numbering for the device follows mmcblk0 -> mmcblk0p1 format.
else
  mkfs.vfat "$1"p1
  mount "$1"p1 boot
  mkfs.ext4 "$1"p2
  mount "$1"p2 root
fi

## Download tarball 
SRC="http://archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz" #RasPi
#SRC="http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz" #RasPi 2
wget $SRC

## Download and verify PGP signature
## (Best practice, but disabled for simplicity's sake.)
#wget "$SRC".sig
#gpg --recv-keys 2BDBE6A6
#gpg --verify $SRC

## Extract tarball
tar -xf ArchLinuxARM-rpi-latest.tar.gz -C root 
sync
mv root/boot/* boot   # Move /boot files to boot partition
sync

## Add build script to homedir
cp build.sh root/home/alarm/

## Change alarm's password from default
SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
echo -n "Update alarm's password: "
read -s PASS
echo
HASH=$(mkpasswd  -m sha-512 -S $SALT -s <<< $PASS)
sed -i "s~alarm:[^:]\+:~alarm:$HASH:~" root/etc/shadow

## Change root's password from default
SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
echo -n "Update root's password: "
read -s PASS
echo
HASH=$(mkpasswd  -m sha-512 -S $SALT -s <<< $PASS)
sed -i "s~root:[^:]\+:~root:$HASH:~" root/etc/shadow

## Unmount mounts
sync
umount boot root
# rm -r boot root
# rm ArchLinuxARM-rpi-2-latest.tar.gz

## We're done.
