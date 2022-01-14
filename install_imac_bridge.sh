#!/bin/bash

FILENAME=$0
# Argument 1 to error_check() is the line at which the errored comand
# occurred. $LINENO-1 is usually that value.
function error_check() {
    if (( $? == 1 )); then
	# print the error and the line from the file on one line in
	# the terminal
	echo -ne "\e[31mError occured at line $1: \e[39m"
	# sed trick from https://stackoverflow.com/a/6022431
	echo $(sed "$1q;d" $FILENAME)
	exit 1
    fi
}

# print $1 with the colored line front
function status_message() {
    echo -e "\e[92m$FILENAME:\e[39m $1"
}
# All the networking things in this script come from
# https://forums.raspberrypi.com/viewtopic.php?t=223295

# update package index
status_message "Updating system..."
sudo apt update
error_check $(($LINENO - 1))
sudo apt upgrade
error_check $(($LINENO - 1))

status_message "Installing necessary tools..."
sudo apt install dnsmasq git build-essential wget -y
error_check $(($LINENO - 1))
# do stuff to set up the server
# first we have to configure iptables to use iptables-legacy
status_message "Configuring 'iptables' to be 'iptables-legacy'..."
echo "iptables                       manual   /usr/sbin/iptables-legacy" | sudo update-alternatives --set-selections 
error_check $(($LINENO - 1))

status_message "Configuring dhcpcd..."
echo "interface eth0" | sudo tee -a /etc/dhcpcd.conf
error_check $(($LINENO - 1))
echo "static ip_address=192.168.4.1/24" | sudo tee -a /etc/dhcpcd.conf
error_check $(($LINENO - 1))

status_message "Configuring dnsmasq..."
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
error_check $(($LINENO - 1))
echo "interface=eth0" | sudo tee -a /etc/dnsmasq.conf
error_check $(($LINENO - 1))
echo "dhcp-range=192.168.4.8,192.168.4.250,255.255.255.0,12h" | sudo tee -a /etc/dnsmasq.conf
error_check $(($LINENO - 1))

status_message "Enabling packet routing..."
sudo sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
error_check $(($LINENO - 1))
# now all the hard stuff is done, we can set up carl

# clone cryanc
status_message "Cloning Crypto Ancienne..."
git clone https://github.com/classilla/cryanc
error_check $(($LINENO - 1))
status_message "Building and installing carl (warnings about POSIX-SUS are not an issue)..."
cd cryanc
gcc -O3 -o carl carl.c
error_check $(($LINENO - 1))
strip carl
error_check $(($LINENO - 1))
sudo cp carl /usr/local/bin
error_check $(($LINENO - 1))

# get and install micro_inetd
status_message "Downloading micro_inetd..."
wget https://acme.com/software/micro_inetd/micro_inetd_14Aug2014.tar.gz
error_check $(($LINENO - 1))
status_message "Building and installing micro_inetd..."
tar xf micro_inetd_14Aug2014.tar.gz
error_check $(($LINENO - 1))
cd micro_inetd
make
error_check $(($LINENO - 1))
strip micro_inetd
error_check $(($LINENO - 1))
sudo cp micro_inetd /usr/local/bin
error_check $(($LINENO - 1))

# we have to place a few lines before the 'exit 0' in rc.local. I
# think this is the best way to do it: remove 'exit 0', write in new
# lines, write in 'exit 0'.

status_message "Enabling iptables routing and carl on boot..."
sudo sed -i 's/exit 0//g' /etc/rc.local
error_check $(($LINENO - 1))
echo "iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE" | sudo tee -a /etc/rc.local
error_check $(($LINENO - 1))
# have to use full paths, otherwise carl (or maybe micro_inetd) sends back 'execl: No such file or directory'

echo "/usr/local/bin/micro_inetd 6789 /usr/local/bin/carl -p" | sudo tee -a /etc/rc.local
error_check $(($LINENO - 1))
echo "exit 0" | sudo tee -a /etc/rc.local
error_check $(($LINENO - 1))
status_message "Finished. Please reboot."
