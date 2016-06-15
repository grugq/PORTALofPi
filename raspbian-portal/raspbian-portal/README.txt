This software builds upon what Robin Newman wrote which routes an
Internet connection through the wireless interface of a raspberry pi
The original software was downloaded from Robin Newman's blog at
https://rbnrpi.wordpress.com/project-list/wifi-to-ethernet-adapter-for-an-ethernet-ready-tv/

I have modified it to route a data connection from the ethernet
port out through the wi-fi interface of the pi such that the
outgoing traffic is sent over Tor.

This folder contains files for setting up a raspberry pi to route your
traffic over Tor.  Here's a basic overview of how this would look.
(Diagram borrowed from the grugq https://github.com/grugq/PORTALofPi/blob/master/build.sh )
*****************************************************************

((laptop))----[eth0]<[Pi]>[USB Wi-Fi dongle]----((Internet))

*****************************************************************

contents:
  scripts:
    installer.sh
	setupiptables
	resetiptables
	setuproutes
  config files:
	interfaces
	sysctl.conf	
	dhcpd.conf
	
Quick installtion

Before you start the installation type 
  sudo apt-get update
once that is complete type
  sudo bash ./installer.sh
the installer.sh script will run all the commands necessary and download
all software necessary for your raspberry pi to route your traffic over
Tor.


When the boot sequence ends you should see ip addresses 192.168.2.1 and 192.168.1.98
listed. type route
you should see

Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         192.168.1.1     0.0.0.0         UG    0      0        0 wlan0
192.168.1.0     *               255.255.255.0   U     0      0        0 wlan0
192.168.2.0     *               255.255.255.0   U     0      0        0 eth0

to test that you are connected to the internet through Tor go to 
https://check.torproject.org on your laptop


That completes the configuration



Notes:

There already exists a guide on adafruit on how to turn your raspberry pi
into a wireless access point, which routes your traffic over Tor.
Sometimes you do not want your ISP to know you are using Tor at your home
location so this isn't always practical.  However if this software is 
installed on your raspberry pi, you can now bring this pi to any location
where Wi-Fi is available and have your traffic be sent through your
ethernet connection --> Pi ---> Tor.  

The Grugq wrote his original PORTALofPi software to be compatible with
archLinux on the raspberry pi.  Sometimes it is not easy getting 
arch linux onto your raspberry pi, but getting raspbian is pretty easy.
So I decided to try and replicate The Grugq's script here, just modified
slightly to work on raspbian.

The setupiptables and resetiptables scripts do not have to be used unless you 
are going to configure different addresses for the project.

The files assume the main network router is on 192.168.1.1 and that it
supplies DNS at the same address. The Rpi wlan is given a static address of
192.168.1.98  The ethernet interface is given a static address of 192.168.2.1 
and serves DHCP addresses in the range 192.168.2,10 to 192.168.2.20 with DNS
on 192.168.1.1 The Rpi routes all unknown address packets to 192.168.1.1
via the wireless interface.
