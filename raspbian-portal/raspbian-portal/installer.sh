# backup the existing /etc/interfaces file to /etc/network/interfaces.bak
echo "backing up /etc/network/interfaces to /etc/network/interfaces.bak"
sudo cp /etc/network/interfaces /etc/network/interfaces.bak

# edit ~/tvrouter/interfaces to use the wi-fi SSID and optional psk
echo -n "Enter wifi name and press [ENTER]: "
read  ssid
echo -n "Enter wifi password and press [ENTER] (leave blank if no passwd): "
read  psk
sed -i "s/wpa-ssid \".*\"/wpa-ssid \"$ssid\"/" interfaces
sed -i "s/wpa-psk \".*\"/wpa-psk \"$psk\"/" interfaces

# copy the interfaces file to the /etc/network directory
echo "copying ~/raspbian-portal/interfaces to /etc/network"
sudo cp interfaces /etc/network

#copy the iptables file to the /etc/network director
echo "copying ~/raspbian-portal/iptables to /etc/network"
sudo cp iptables /etc/network

# for safety backup the xisting sysctl.conf file
echo "backing up /etc/sysctl.conf to /etc/sysctl.conf.bak"
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak

# copy the sysctl.conf file to the /etc directory
echo "copying ~/raspbian-portal/sysctl.conf to /etc.."
sudo cp sysctl.conf /etc

# enable the changes
echo "enabling sysctl changes.."
sudo sysctl --system

#copy the setuproutes script to the /etc/init.d directory
echo "adding ~/raspbian-portal/setuproutes script to /etc/init.d for on-startup"
sudo cp setuproutes /etc/init.d

# activate the setuproutes script for auto run on boot
echo "activating the setuproutes script for auto run on boot"
sudo update-rc.d setuproutes defaults

# install the dhcp server
echo "installing isc-dhcp-server"
sudo apt-get install isc-dhcp-server

# backup the original dhcp configuration file
echo "backing up /etc/dhcp/dhcpd.conf to /etc/dhcp/dhcp.conf.bak"
sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcp.conf.bak

# copy the dhcpd.conf file to the /etc/dhcp directory
echo "copying ~/rasbian-portal/dhcpd.conf to /etc/dhcp"
sudo cp dhcpd.conf /etc/dhcp

# install tor
echo "installing tor now.."
sudo apt-get install tor

# make a backup of the default torrc
echo "making backup of default torrc at /etc/tor/torrc.bak"
sudo cp /etc/tor/torrc /etc/tor/torrc.bak

# This is the config for Tor, lets set it up:
echo "copying ~/raspbian-portal/torrc to /etc/tor/torrc"
sudo cp torrc /etc/tor/torrc

# so we can ssh into our raspberry pi after all this
echo "adding ssh access to iptables"
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 22 -j REDIRECT --to-ports 22

# route all DNS on eth0 from 53 to 9053
echo "forwarding DNS on port 53 via interface eth0 to 9053"
sudo iptables -t nat -A PREROUTING -i eth0 -p udp --dport 53 -j REDIRECT --to-ports 9053

# route all tcp traffic on interface eth0 to port 9040 (TransPort in torrc)
echo "route all tcp traffic on eth0 to port 9040 (TransPort in torrc)"
sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --syn -j REDIRECT --to-ports 9040

echo "saving current iptables file to /etc/network/iptables"
sudo sh -c "iptables-save > /etc/network/iptables"

# reboot the raspberry pi
echo "rebooting raspberry pi now"
sudo shutdown -r now
