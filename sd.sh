#!/bin/bash
if [ -z $1 ] 
then
    echo "USAGE: $0 /dev/sdX"
    exit
fi
target=$1

# do fdisk
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

mkfs.vfat $target"1"
mkdir boot
mount $target"1" boot

mkfs.ext4 $target"2"
mkdir root
mount $target"2" root

wget http://archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz
bsdtar -xpf ArchLinuxARM-rpi-2-latest.tar.gz -C root

echo "SYNC -- THIS MIGHT TAKE SOME MINUTES"
sync

ls root/boot
rsync -abmv --remove-source-files root/boot/* boot
find root/boot -depth -type d -empty -delete

cp build.sh root/home/alarm/

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

echo "SYNC -- JUST TO BE SAFE"
sync

umount boot root
rm -r boot root
rm ArchLinuxARM-rpi-2-latest.tar.gz
