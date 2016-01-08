#!/bin/bash
#  ___  ___  ___ _____ _   _
# | _ \/ _ \| _ \_   _/_\ | | of  _ o  
# |  _/ (_) |   / | |/ _ \| |__  |_)|  
# |_|  \___/|_|_\ |_/_/ \_\____| |
#
# Licensed GPLv3
#
# (c) 2013 the grugq <the.grugq@gmail.com>
# modified 2k16 by TACIXAT

# See the README.md for indepth details. (loljk the README sucks)
#
# Based on the RaspberryPi Arch image from here:
#  http://www.raspberrypi.org/downloads
# specifically:
#  http://archlinuxarm.org/platforms/armv7/broadcom/raspberry-pi-2

# THIS SETUP HAS NOT BEEN PUBLICLY AUDITED - USE AT YOUR OWN RISK

# PORTAL configuration overview
#  
# ((Internet))---[eth1 USB]<[Pi]>[eth0]----((LAN))
#   eth0: 172.16.0.1
#        * anything from here can only reach 9050 (Tor proxy) or,
#        * the transparent Tor proxy 
#    USB: eth1
#        * Auto DHCP
#        * Get a USB ethernet adapter
#        * http://elinux.org/RPi_USB_Ethernet_adapters
#        * Buy it in person with cash
#        * Wear a cap and sunglasses in to the store like a cool hacker

# STEP 1 !!! (of 1)
#   configure Internet access, we'll neet to install some basic tools.


# Do this manually
# alarm's password is alarm
# root's password is root
#echo "Change alarm's password!"
#echo "Password requirements, at least 10000 characters, 40% of which must be emoji."
# change alarm's password
#passwd
# once you go root
#su

echo "Change root's password!"
# change root's password
passwd

# update pacman
pacman -Syu

# install a comfortable work environment
# yaourt didn't install for me, so fuck it
#pacman -S yaourt
#pacman -S zsh grml-zsh-config htop lsof strace
pacman -S vim

# optional if you're going to be doing work
# set up sudo because pkgbuild can't be run as root
pacman -S sudo
# optional give alarm sudo
echo "alarm ALL=(ALL) ALL" >> /etc/sudoers

# install dnsmasq for DHCP on eth0
pacman -S dnsmasq

# Install Tor
pacman -S tor

# Install NTP
pacman -S ntp

pacman -S macchanger

# install an HTTP proxy, optional
# isn't caching your web traffic a shitty idea?
#pacman -S polipo

# install development tools for building tlsdate
#pacman -S base-devel
pacman -S binutils autoconf automake libtool pkg-config gcc make fakeroot gettext

# set hostname to PORTAL \m/
#TK randomize this?
echo "portal" > /etc/hostname

#TK memory wiper
#some application that goes through free(d?) memory and wrecks it
#mimic forensic tools but make it lite

#TK can we alias rm to shred? 
#what are the implications on an SD card?

#TK mangle modification dates to fuck with forensics?

#TK check IP tables against https://lists.torproject.org/pipermail/tor-talk/2012-October/026226.html

#TK disk encryption, how will this affect speed?

# build tlsdate 
curl https://aur.archlinux.org/cgit/aur.git/snapshot/tlsdate.tar.gz > tlsdate.tar.gz
tar -xvzf tlsdate.tar.gz
chown alarm:alarm tlsdate -R
cd tlsdate
sudo -u alarm makepkg -sri
cp tlsdate.service /etc/systemd/system/
systemctl enable tlsdate.service
cd ..

# set up eth1 for usb to internet connection
sed -i 's/eth0/eth1/g' /etc/systemd/network/eth0.network
mv /etc/systemd/network/eth0.network /etc/systemd/network/eth1.network

# Setup the hardware random number generator
# I keep mistyping bmc, I blame bmc
echo "bcm2708_rng" > /etc/modules-load.d/bcm2708-rng.conf
pacman -Sy rng-tools
systemctl enable rngd

#set the time to UTC, because that's how we roll
rm /etc/localtime
ln -s /usr/share/zoneinfo/UTC /etc/localtime

# This is the config for Tor, lets set it up:
cat > /etc/tor/torrc << __TORRC__
## CONFIGURED FOR ARCHLINUX

## Replace this with "SocksPort 0" if you plan to run Tor only as a
## server, and not make any local application connections yourself.
SocksPort 9050 # port to listen on for localhost connections
# SocksPort 127.0.0.1:9050 # functionally the same as the line above 
SocksPort 172.16.0.1:9050 # listen on a chosen IP/port too

## Allow no-name routers (ones that the dirserver operators don't
## know anything about) in only these positions in your circuits.
## Other choices (not advised) are entry,exit,introduction.
AllowUnverifiedNodes middle,rendezvous

Log notice syslog

DataDirectory /var/lib/tor

## The port on which Tor will listen for local connections from Tor controller
## applications, as documented in control-spec.txt.  NB: this feature is
## currently experimental.
#ControlPort 9051

VirtualAddrNetwork 10.192.0.0/10             
AutomapHostsOnResolve 1                                              
TransPort 172.16.0.1:9040                                                          
DNSPort 172.16.0.1:9053                                                              

__TORRC__

# take over eth0 for computer to pi connection
cat > /etc/conf.d/network << __ETHCONF__
interface=eth0
address=172.16.0.1
netmask=24
broadcast=172.16.0.255
iface2=eth1
__ETHCONF__

cat > /etc/systemd/system/network.service << __ETHRC__
[Unit]
Description=WStatic IP Connectivity
Wants=network.target
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
EnvironmentFile=/etc/conf.d/network
ExecStart=/sbin/ip link set dev \${interface} up
#ExecStart=/usr/sbin/wpa_supplicant -B -i \${interface} -c /etc/wpa_supplicant.conf # Remove this for wired connections
ExecStart=/sbin/ip addr add \${address}/\${netmask} broadcast \${broadcast} dev \${interface}
#ExecStart=/sbin/ip route add default via \${gateway}
 
ExecStop=/sbin/ip addr flush dev \${interface}
ExecStop=/sbin/ip link set dev \${interface} down

[Install]
WantedBy=multi-user.target
__ETHRC__

systemctl enable network.service

# randomize your mac addr
# this doesn't seem to work if you do iface2 before interface ???
cat > /etc/systemd/system/macchanger.service << __MACRC__
[Unit]
Description=Randomize MAC Addies
After=network.service
Requires=network.servce

[Service]
Type=oneshot
RemainAfterExit=yes
EnvironmentFile=/etc/conf.d/network
ExecStart=/sbin/ip link set dev \${interface} down
ExecStart=/sbin/macchanger -r \${interface}
ExecStart=/sbin/ip link set dev \${interface} up
ExecStart=/sbin/ip link set dev \${iface2} down
ExecStart=/sbin/macchanger -r \${iface2}
ExecStart=/sbin/ip link set dev \${iface2} up

[Install]
WantedBy=multi-user.target
__MACRC__

systemctl enable macchanger.service

systemctl enable ntpd.service

#TK read code to see what this is doing
# patch ntp-wait: strange unresolved bug
sed -i 's/$leap =~ \/(sync|leap)_alarm/$sync =~ \/sync_unspec/' /usr/bin/ntp-wait
sed -i 's/$leap =~ \/leap_(none|((add|del)_sec))/$sync =~ \/sync_ntp/' /usr/bin/ntp-wait

cat > /usr/lib/systemd/system/ntp-wait.service << __NTPWAIT__
[Unit]
Description=Wait for Network Time Service to synchronize
After=ntpd.service
Requires=ntpd.service

[Service]
Type=oneshot
ExecStart=/usr/bin/ntp-wait -n 5

[Install]
WantedBy=multi-user.target
__NTPWAIT__

systemctl enable ntp-wait.service

# configure dnsmasq
cat > /etc/dnsmasq.conf << __DNSMASQ__
bogus-priv
filterwin2k
interface=eth0
bind-interfaces

dhcp-range=172.16.0.50,172.16.0.150,12h

# For debugging purposes, log each DNS query as it passes through
# dnsmasq.
# XXX this is actually a good idea, particularly if you want to look for indicators of compromise.
#log-queries
__DNSMASQ__

# enable the dnsmasq daemon
systemctl enable dnsmasq.service

# setup the iptables rules
cat > /etc/iptables/iptables.rules << __IPTABLES__
# Generated by iptables-save v1.4.16.3 on Thu Jan  1 01:24:22 1970
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A PREROUTING -i eth0 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040
-A PREROUTING -i eth0 -p udp -m udp --dport 53 -j REDIRECT --to-ports 9053
COMMIT
# Completed on Thu Jan  1 01:24:22 1970
# Generated by iptables-save v1.4.16.3 on Thu Jan  1 01:24:22 1970
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [64:3712]
-A INPUT -p icmp -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i eth0 -p tcp -m tcp --dport 9050 -j ACCEPT
-A INPUT -i eth0 -p tcp -m tcp --dport 9040 -j ACCEPT
-A INPUT -i eth0 -p udp -m udp --dport 9053 -j ACCEPT
-A INPUT -i eth0 -p udp -m udp --dport 67 -j ACCEPT
-A INPUT -p tcp -j REJECT --reject-with tcp-reset
-A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
-A INPUT -j REJECT --reject-with icmp-proto-unreachable
COMMIT
# Completed on Thu Jan  1 01:24:22 1970 ## truf!
__IPTABLES__

systemctl enable iptables.service

# patch tor service: wait for ntpd to synchronize
sed -i 's/After=network.target/After= network.target ntp-wait.service/' /usr/lib/systemd/system/tor.service

# turn on tor, and reboot... it should work. 
systemctl enable tor.service

# ramfs grows dynamically
# tmpfs has limited size but can use swap
# pick your poison
echo "tmpfs /var/log tmpfs nodev,nosuid,size=16M 0 0" >> /etc/fstab
rm -R /var/log

echo "tmpfs /tmp tmpfs nodev,nosuid,size=16M 0 0" >> /etc/fstab
rm -R /tmp

#shread ~/.bash_history
#shread /home/alarm/.bash_history

sync && reboot
