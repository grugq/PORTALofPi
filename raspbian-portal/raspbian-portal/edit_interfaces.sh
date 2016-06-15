# edit ~/tvrouter/interfaces to use the wi-fi SSID and optional psk
echo -n "Enter wifi name and press [ENTER]: "
read  ssid
echo -n "Enter wifi password and press [ENTER] (leave blank if no passwd): "
read  psk
sed -i "s/wpa-ssid \".*\"/wpa-ssid \"$ssid\"/" interfaces
sed -i "s/wpa-psk \".*\"/wpa-psk \"$psk\"/" interfaces
#sed -i -e "19s/.*/wpa-ssid \"$ssid\"/" interfaces
#sed -i -e "20s/.*/wpa-psk \"$psk\"/" interfaces
#sed -i -e "s/wpa-ssid*/wpa-ssid \"$ssid\"/"  interfaces
#sed -i -e "s/wpa-psk*/'wpa-psk \"$psk\"/" interfaces
