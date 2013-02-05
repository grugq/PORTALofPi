#!/bin/bash
#
# Licensed GPLv3
#
# (c) 2013 the grugq <the.grugq@gmail.com>

# See the README.md for indepth details.
#
# Based on the RaspberryPi Arch image from here:
#  http://www.raspberrypi.org/downloads
# specifically:
#  http://downloads.raspberrypi.org/images/archlinuxarm/archlinux-hf-2012-09-18/archlinux-hf-2012-09-18.zip

# PORTAL configuration overview
#  
# ((Internet))---[USB]<[Pi]>[eth0]----((LAN))
#   eth0: 172.16.0.1
#        * anything from here can only reach 9050 (Tor proxy) or,
#        * the transparent Tor proxy 
#    USB: ???.
#        * Internet access. You're on your own
#        * No services exposed here

# STEP 1 !!! 
#   configure Internet access, we'll neet to install some basic tools.

# update pacman
echo "## Checking for updates ##"
pacman -Syu

# install a comfortable work environment, dnsmasq for DHCP on eth0, Tor, and polipo (an HTTP proxy (optional))
echo "## Installing a few tools and the essentials to get Tor up and running ##"
pacman -S yaourt zsh grml-zsh-config vim htop lsof strace dnsmasq tor polipo

# This is the config for Tor, lets set it up:
echo "## Replacing torrc ##"
mv /etc/tor/torrc /etc/tor/torrc.old 2>/dev/null
cat configfiles/torrc >> /etc/tor/torrc

# set up the ethernet
echo "## Replacing network.service ##"
mv /etc/systemd/system/network.service /etc/systemd/system/network.service.old 2>/dev/null
cat configfiles/network.service >> /etc/systemd/system/network.service
systemctl enable network.service

# configure dnsmasq
echo "## Replacing dnsmasq.conf ##"
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old 2>/dev/null
cat configfiles/dnsmasq.conf >> /etc/dnsmasq.conf
systemctl enable dnsmasq.service

# setup the iptables rules
echo "## Replacing and enabling iptables.rules ##"
mv /etc/iptables/iptables.rules /etc/iptables/iptables.rules.old 2>/dev/null
cat configfiles/iptables.rules >> /etc/iptables/iptables.rules
systemctl enable iptables.service

# turn on tor, and reboot... it should work.
echo "## Enabling Tor ##"
systemctl enable tor.service

echo "Make sure your connection to the internet is up, set it up if not, and then reboot."
