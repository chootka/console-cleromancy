#! /bin/bash
#
# Raspberry Pi network configuration / AP install script
# Sarah Grant
# Updated 18 Sept 2015
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SOME DEFAULT VALUES
#

# WIRELESS RADIO DRIVER
RADIO_DRIVER=nl80211

# ACCESS POINT
AP_COUNTRY=US
AP_SSID=FΩR†UNE †elne†
AP_CHAN=6

# WLAN STATIC IP
WLAN_IP=192.168.100.1

# DNSMASQ STUFF
DHCP_START=192.168.100.101
DHCP_END=192.168.100.254
DHCP_NETMASK=255.255.255.0
DHCP_LEASE=1h

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CHECK USER PRIVILEGES
(( `id -u` )) && echo "This script *must* be ran with root privileges, try prefixing with sudo. i.e sudo $0" && exit 1

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# BEGIN INSTALLATION PROCESS
#
echo "//////////////////////////////"
echo "// Welcome to FΩR†UNE †elne†"
echo "// ~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo ""

read -p "This installation script will configure a wireless access point for your FΩR†UNE †elne†. Make sure you have a USB wifi radios connected to your Raspberry Pi before proceeding. Press any key to continue..."
echo ""
#
# CHECK USB WIFI HARDWARE IS FOUND
# also, i will need to check for one device per network config for a total of two devices
if [[ -n $(lsusb | grep RT5370) ]]; then
    echo "The RT5370 device has been successfully located."
else
    echo "The RT5370 device has not been located, check it is inserted and run script again when done."
    exit 1
fi
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# SOFTWARE INSTALL
#
# update the packages
echo "Updating apt-get and installing hostapd, dnsmasq, and iw package for network interface configuration..."
apt-get update && apt-get install -y iw hostapd dnsmasq

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# CONFIGURE AN ACCESS POINT WITH CAPTIVE PORTAL?
#
clear
echo "//////////////////////////////////"
echo "// Access Point Settings"
echo "// ~~~~~~~~~~~~~~~~~~~~~"
echo ""
read -p "Do you wish to continue and set up your Raspberry Pi as a Clairvoyant Access Point? [N] " yn
case $yn in
	[Yy]* )
		clear
		echo "Configuring Raspberry Pi as a Clairvoyant Access Point, capable of seeing your future..."
		echo ""

		# check that iw list does not fail with 'nl80211 not found'
		echo -en "checking that nl80211 USB wifi radio is plugged in...				"
		iw list > /dev/null 2>&1 | grep 'nl80211 not found'
		rc=$?
		if [[ $rc = 0 ]] ; then
			echo -en "[FAIL]\n"
			echo "Make sure you are using a wifi radio that runs via the nl80211 driver."
			exit $rc
		else
			echo -en "[OK]\n"
		fi

		# ask how they want to configure their access point
		read -p "wlan static IP [$WLAN_IP]: " -e t1
		if [ -n "$t1" ]; then WLAN_IP="$t1";fi

		read -p "Wifi Country [$AP_COUNTRY]: " -e t1
		if [ -n "$t1" ]; then AP_COUNTRY="$t1";fi

		read -p "Wifi Channel Name [$AP_CHAN]: " -e t1
		if [ -n "$t1" ]; then AP_CHAN="$t1";fi

		read -p "Wifi SSID [$AP_SSID]: " -e t1
		if [ -n "$t1" ]; then AP_SSID="$t1";fi

		read -p "Bridge Subnet Mask [$BRIDGE_NETMASK]: " -e t1
		if [ -n "$t1" ]; then AP_CHAN="$t1";fi

		read -p "DHCP starting address [$DHCP_START]: " -e t1
		if [ -n "$t1" ]; then DHCP_START="$t1";fi

		read -p "DHCP ending address [$DHCP_END]: " -e t1
		if [ -n "$t1" ]; then DHCP_END="$t1";fi

		read -p "DHCP netmask [$DHCP_NETMASK]: " -e t1
		if [ -n "$t1" ]; then DHCP_NETMASK="$t1";fi

		read -p "DHCP length of lease [$DHCP_LEASE]: " -e t1
		if [ -n "$t1" ]; then DHCP_LEASE="$t1";fi

		# create hostapd init file
		echo -en "Creating default hostapd file...			"
		cat <<EOF > /etc/default/hostapd
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF
			rc=$?
			if [[ $rc != 0 ]] ; then
				echo -en "[FAIL]\n"
				echo ""
				exit $rc
			else
				echo -en "[OK]\n"
			fi

		# create hostapd configuration with user's settings
		echo -en "Creating hostapd.conf file...				"
		cat <<EOF > /etc/hostapd/hostapd.conf
interface=wlan0
driver=$RADIO_DRIVER
country_code=$AP_COUNTRY
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
ssid=$AP_SSID
hw_mode=g
channel=$AP_CHAN
beacon_int=100
auth_algs=1
wpa=0
macaddr_acl=0
EOF
			rc=$?
			if [[ $rc != 0 ]] ; then
				echo -en "[FAIL]\n"
				exit $rc
			else
				echo -en "[OK]\n"
			fi

		# backup the existing interfaces file
		echo -en "Creating backup of network interfaces configuration file... 			"
		cp /etc/network/interfaces /etc/network/interfaces.bak
		rc=$?
		if [[ $rc != 0 ]] ; then
			echo -en "[FAIL]\n"
			exit $rc
		else
			echo -en "[OK]\n"
		fi

		# CONFIGURE /etc/network/interfaces
		echo -en "Creating new network interfaces configuration file with your settings... 	"
		cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
allow-hotplug eth0
iface eth0 inet manual

auto wlan0
allow-hotplug wlan0
iface wlan0 inet static
address $WLAN_IP
netmask 255.255.255.0
EOF
		rc=$?
		if [[ $rc != 0 ]] ; then
    			echo -en "[FAIL]\n"
			echo ""
			exit $rc
		else
			echo -en "[OK]\n"
		fi

		# CONFIGURE dnsmasq
		echo -en "Creating dnsmasq configuration file... 			"
		cat <<EOF > /etc/dnsmasq.conf
interface=wlan0
address=/#/$WLAN_IP
address=/apple.com/0.0.0.0
dhcp-range=$DHCP_START,$DHCP_END,$DHCP_NETMASK,$DHCP_LEASE
EOF
		rc=$?
		if [[ $rc != 0 ]] ; then
    			echo -en "[FAIL]\n"
			echo ""
			exit $rc
		else
			echo -en "[OK]\n"
		fi

		# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
		# COPY OVER THE ACCESS POINT START UP SCRIPT + enable services
		#
		clear
		update-rc.d hostapd enable
		update-rc.d dnsmasq enable
		cp scripts/fortune-telnet.sh /etc/init.d/fortune-telnet
		chmod 755 /etc/init.d/fortune-telnet
		update-rc.d fortune-telnet defaults
	;;

	[Nn]* ) ;;
esac

#exit 0

read -p "Do you wish to reboot the crystal ball now? [N] " yn
	case $yn in
		[Yy]* )
			reboot;;
		Nn]* ) exit 0;;
	esac
