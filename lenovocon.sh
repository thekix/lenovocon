#!/bin/bash

# Lenovo con script
# Rodolfo García Peñas (kix) <kix@kix.es> 20190925

# Set the APN
IFACE="wwp0s20u4";
APN="Movistar";

function connect()
{
	# First, get the device number, something like:
	## mmcli -L
	#/org/freedesktop/ModemManager1/Modem/1
	DEV=`mmcli -L | grep "ModemManager" | cut -d\[ -f1 | cut -d/ -f6 | sed "s/ //g"`

	if [ "$DEV" = "" ]
	then
		exit -1;
	fi

	echo "Device found: $DEV"

	# My laptop, x240 has a problem with ModemManager
	# if the Status is 'sim-missing', I need to suspend the device
	# closing the lid, then the device can be used
	OUT=`mmcli -m $DEV`;
	if [ $? -ne 0 ]
	then
		echo "Error getting the device info";
		exit -1;
	fi

	OUT=`echo $OUT | grep 'sim-missing'`;
	if [ "$OUT" = "" ]
	then
		echo "Device is OK, continue";
	else
		echo "Close the LID";
		exit -1;
	fi

	# Get the SIM number
	SIM=`mmcli -m $DEV | grep SIM | cut -d/ -f6 | sed "s/ //g"`;
	if [ SIM = "" ]
	then
		echo "Error reading the SIM value";
		exit -1;
	fi

	echo "SIM Card found for device $DEV. Number $SIM"

	OUT=`mmcli -i "$SIM" --pin "$PIN"`;
	if [ $? -ne 0 ]
	then
		echo "Pin number error";
		exit -1;
	fi

	echo "SIM PIN OK"

	echo "Connecting..."

	OUT=`mmcli -m $DEV --simple-connect="apn=$APN,ip-type=ipv4"`
	if [ $? -ne 0 ]
	then
		echo "Connecting error";
		exit -1;
	fi

	echo "Connection ok, getting the Bearers"

	BEARER=`mmcli -m $DEV | grep Bearer | cut -d/ -f6`
	if [ BEARER = "" ]
	then
		echo "Error reading the Bearer value";
		exit -1;
	fi

	echo "Bearer OK. Readed $BEARER. Getting connection info."

	IPADDRESS=`mmcli -b $BEARER | grep address | cut -d: -f2`;
	IPGATEWAY=`mmcli -b $BEARER | grep gateway | cut -d: -f2`;

	## mmcli -b 0
	#  --------------------------------
	#  General            |  dbus path: /org/freedesktop/ModemManager1/Bearer/0
	#                     |       type: default
	#  --------------------------------
	#  Status             |  connected: yes
	#                     |  suspended: no
	#                     |  interface: wwp0s20u4
	#                     | ip timeout: 20
	#  --------------------------------
	#  Properties         |        apn: Movistar
	#                     |    roaming: allowed
	#                     |    ip type: ipv4
	#  --------------------------------
	#  IPv4 configuration |     method: static
	#                     |    address: 10.27.237.39
	#                     |     prefix: 24
	#                     |    gateway: 10.27.237.1
	#                     |        dns: 80.58.61.250, 80.58.61.254
	#  --------------------------------

	if [ IPADRESS = "" ] || [ IPGATEWAY = "" ]
	then
		echo "Error reading the IPv4 values";
		exit -1;
	fi

	echo "Running: ifconfig $IFACE $IPADDRESS";
	ifconfig $IFACE $IPADDRESS
	echo "Running: route del default";
	route del default
	echo "Running: route add default gw $IPGATEWAY";
	route add default gw $IPGATEWAY

	# Tests
	ping -c 3 8.8.8.8
	netstat -nr
}

function disconnect()
{
	# First, get the device number, something like:
	## mmcli -L
	#/org/freedesktop/ModemManager1/Modem/1
	DEV=`mmcli -L | grep "ModemManager" | cut -d\[ -f1 | cut -d/ -f6 | sed "s/ //g"`

	if [ "$DEV" = "" ]
	then
		exit -1;
	fi

	echo "Disconnecting";
	mmcli -m $DEV --simple-disconnect

	echo "Shutting down interface $IFACE";
	ifconfig $IFACE down

	echo "Current routing table";
	# ip route or...
	netstat -nr

	# Configure your own stuff
	echo "Adding the new default route";
	route add default gw 192.168.1.1

	echo "Current routing table (new)";
	# ip route or...
	netstat -nr
}

# Main stuff

# Get the option
if [[ $# -ne 1 ]]
then
	echo "  Usage: $0 <pin>|off";
	echo "";
	echo "  Connect:    $0 1234";
	echo "  Disconnect: $0 off";
	echo "";
	echo "  Check in the script your APN and the interface name";
	echo "  If you are not using PIN, modify the script ;-)";
	echo "";
	exit -1;
fi

PIN=$1;

if [ "$PIN" = "off" ]
then
	disconnect
else
	connect
fi
