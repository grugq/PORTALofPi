#!/bin/bash

# Source: http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2
# Installation

# SD Card Creation
#     Replace sdX in the following instructions with the device name for the SD card as it appears on your computer.

#     Start fdisk to partition the SD card:
#         fdisk /dev/sdX

#     At the fdisk prompt, delete old partitions and create a new one:
#         Type o. This will clear out any partitions on the drive.
#         Type p to list partitions. There should be no partitions left.
#         Type n, then p for primary, 1 for the first partition on the drive, press ENTER to accept the default first sector, then type +100M for the last sector.
#         Type t, then c to set the first partition to type W95 FAT32 (LBA).
#         Type n, then p for primary, 2 for the second partition on the drive, and then press ENTER twice to accept the default first and last sector.
#         Write the partition table and exit by typing w.
    
#     Create and mount the FAT filesystem:
#         mkfs.vfat /dev/sdX1
#         mkdir boot
#         mount /dev/sdX1 boot

#     Create and mount the ext4 filesystem:
#         mkfs.ext4 /dev/sdX2
#         mkdir root
#         mount /dev/sdX2 root

#     Download and extract the root filesystem (as root, not via sudo):
#         wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
#         bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root
#         sync

#     Move boot files to the first partition:
#         mv root/boot/* boot

#     Unmount the two partitions:
#         umount boot root

# Insert the SD card into the Raspberry Pi, connect ethernet, and apply 5V power.
# Use the serial console or SSH to the IP address given to the board by your router.

# Login as the default user alarm with the password alarm.
# The default root password is root.

if [ -z $1 ] 
then
    echo "USAGE: $0 /dev/sdX"
    exit
fi
target=$1

echo "=== FORMATTING DISK $0"

echo "o
n
p
1

+100M
t
c
n
p
2


w" | fdisk $target

echo "=== MAKING FILESYSTEMS AND MOUNTING"
mkfs.vfat $target"1"
mkdir boot
mount $target"1" boot

mkfs.ext4 $target"2"
mkdir root
mount $target"2" root

echo "=== DOWNLOADING IMAGE"
wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root

echo "=== SYNCING -- THIS MIGHT TAKE SOME MINUTES"
sync

ls root/boot
rsync -abmv --remove-source-files root/boot/* boot
find root/boot -depth -type d -empty -delete

echo "=== COPYING BUILD SCRIPT TO /home/alarm"
cp build.sh root/home/alarm/

echo "=== CHANGE PASSWORDS"
SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
echo -n "Update alarm's password: "
read -s PASS
echo
HASH=$(mkpasswd  -m sha-512 -S $SALT -s <<< $PASS)
sed -i "s~alarm:[^:]\+:~alarm:$HASH:~" root/etc/shadow

SALT=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
echo -n "Update root's password: "
read -s PASS
echo
HASH=$(mkpasswd  -m sha-512 -S $SALT -s <<< $PASS)
sed -i "s~root:[^:]\+:~root:$HASH:~" root/etc/shadow

echo "=== SYNCING -- JUST TO BE SAFE"
sync

echo "=== CLEANUP"
umount boot root
rm -r boot root
rm ArchLinuxARM-rpi-2-latest.tar.gz
