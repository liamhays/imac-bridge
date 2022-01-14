#!/bin/bash

# All the networking things in this script come from
# https://forums.raspberrypi.com/viewtopic.php?t=223295

# update package index
echo Updating package index...
sudo apt update

# start by installing prerequisites
echo Installing necessary tools...
sudo apt install dnsmasq git build-essential wget -y

# do stuff to set up the server
# first we have to configure iptables to use iptables-legacy
echo Configuring 'iptables' to use 'iptables-legacy'...
echo "iptables                       manual   /usr/sbin/iptables-legacy" | sudo update-alternatives --set-selections 

echo Configuring dhcpcd...
echo "interface eth0" | sudo tee -a /etc/dhcpcd.conf
echo "static ip_address=192.168.4.1/24" | sudo tee -a /etc/dhcpcd.conf

echo Configuring dnsmasq...
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo "interface=eth0" | sudo tee -a /etc/dnsmasq.conf
echo "dhcp-range=192.168.4.8,192.168.4.250,255.255.255.0,12h" | sudo tee -a /etc/dnsmasq.conf

echo Enabling packet routing...
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

# now all the hard stuff is done, we can set up carl

# clone cryanc
echo Cloning Crypto Ancienne...
git clone https://github.com/classilla/cryanc

echo "Building and installing carl (warnings about POSIX-SUS are not an issue)..."
cd cryanc
gcc -O3 -o carl carl.c
strip carl
sudo cp carl /usr/local/bin

# get and install micro_inetd
echo Downloading micro_inetd...
wget https://acme.com/software/micro_inetd/micro_inetd_14Aug2014.tar.gz
echo Building and installing micro_inetd
tar xf micro_inetd_14Aug2014.tar.gz
cd micro_inetd
make
strip micro_inetd
sudo cp micro_inetd /usr/local/bin


# we have to place a few lines before the 'exit 0' in rc.local. I
# think this is the best way to do it: remove 'exit 0', write in new
# lines, write in 'exit 0'.

echo Enabling 'iptables' routing and carl on boot...
sudo sed -i 's/exit 0//g' /etc/rc.local
echo "iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE" | sudo tee -a /etc/rc.local
# have to use full paths, otherwise carl (or maybe micro_inetd) sends back 'execl: No such file or directory'

echo "/usr/local/bin/micro_inetd 6789 /usr/local/bin/carl -p" | sudo tee -a /etc/rc.local
echo "exit 0" | sudo tee -a /etc/rc.local

echo Finished. Please reboot.
