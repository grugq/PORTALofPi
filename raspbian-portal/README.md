### PORTAL for raspbian

The Grugq wrote his original PORTALofPi software to be compatible with
archLinux on the raspberry pi.  Some situations do not allow people to
easily get arch linux onto their raspberry pi, but getting raspbian is 
pretty easy.  So I decided to try and replicate The Grugq's script 
here, just modified slightly to work on raspbian.

#### Getting started with raspbian-portal
Connect your raspberry pi to your router either through the wi-fi on 
your raspberry pi or directly via [Pi]--- ethernet --- [wi-fi router]

After ssh-ing into your raspberry pi enter the following commands.

```
cd raspbian-portal/raspbian-portal
sudo bash installer.sh
```

You will be prompted to install some software (such as Tor, if it is
not already installed) along with some questions about the network 
you are looking to join.

Once the installation is complete your raspberry pi will begin restarting.
In order to change the wi-fi network you want to connect to you must
change the wpa_configuration file located at ` /etc/network/interfaces `
