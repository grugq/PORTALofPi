```html
  ___  ___  ___ _____ _   _
 | _ \/ _ \| _ \_   _/_\ | | of  _ o  
 |  _/ (_) |   / | |/ _ \| |__  |_)|  
 |_|  \___/|_|_\ |_/_/ \_\____| |
```

PORTAL of Pi - RaspberyPi based PORTAL device. 

Development and Design Guide
=============================

By: the grugq <thegrugq@gmail.com>

Fork: @TACIXAT


Guide
=====

This will guide you through configuring an Arch based RaspberryPi installation
which transparently forwards all TCP traffic over the Tor network. There is 
also a Tor SOCKS proxy for explicitly interacting with the Tor network, either
for more security, or to access a Hidden Service.

This fork is intended to do a little more heavy lifting than the original. 

Requirements: 
	USB ethernet adapter
	Raspberry Pi 2
	SD card
	Computer

sd.sh - Grab an SD card and run sd.sh /dev/sdX. This will format the SD card, 
download the Arch image, load it, change the default passwords, and load the 
init script (build.sh).

build.sh - Boot your RaspberryPi. Connect to some internet (generally, just 
plug into the ethernet jack). Login as alarm, su to a root shell. Run build.sh. 
This should install necessary packages, config files, and services. Reboot.
(Thanks grugq!) 

This setup assumes usage of a USB ethernet adapter. Once setup your connection
should look like:

COMPUTER.ETH ---[]--- PI.USB.ETH -- PI -- PI.ETH ---[]--- INTERNET

Hopefully we will add wifi support in the future, but this will be less of a
plug-n-play solution (since you have to join networks, requires Pi login).

