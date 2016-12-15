#!/bin/bash

# installation for debian
#mv /etc/apt/sources.list /etc/apt/sources.list.$(data +"%Y%m%d-%H%M")

#apt-get update 
#apt-get install puppet facter

if [ ! -z "$(dpkg -l puppet 2>&1 | grep "no packages")" -o ! -z "$(dpkg -l facter 2>&1 | grep 'no packages')" ]
then
	echo "Puppet not installed successfuly. Please try again."
	exit 1
fi

hostname="$(hostname -f)"
server="mds.ioi.com"

# temp file for menu output
OUTPUT=$(mktemp /tmp/usb.XXXXXXX)

# trap and delete temp file
trap "rm $OUTPUT; exit" SIGHUP SIGINT SIGTERM

if [ -d /etc/puppet ]
then
	dialog --inputbox "Enter your hostname" 10 50 "$hostname" 2> $OUTPUT

	hostname=$(<$OUTPUT)

	dialog --inputbox "Enter yasa server" 10 50 "$server" 2> $OUTPUT

	server=$(<$OUTPUT)
	
else
	echo "Puppet not installed completely. Please try again."
	exit 1
	
fi

# create auth.conf
echo "path	/run" > /etc/puppet/auth.conf
echo "method 	save" >> /etc/puppet/auth.conf
echo "auth	any" >> /etc/puppet/auth.conf
echo "allow	$server" >> /etc/puppet/auth.conf

# create puppet.conf agent 
echo "[main]" > /etc/puppet/puppet.conf
echo "    vardir = /var/lib/puppet" > /etc/puppet/puppet.conf
echo "    logdir = /var/log/puppet" >> /etc/puppet/puppet.conf
echo "    rundir = /var/run/puppet" >> /etc/puppet/puppet.conf
echo "    ssldir = /var/lib/puppet/ssl" >> /etc/puppet/puppet.conf
echo "    privatekeydir = $ssldir/private_keys { group = service }" >> /etc/puppet/puppet.conf
echo "    hostprivkey = $privatekeydir/$certname.pem { mode = 640 }" >> /etc/puppet/puppet.conf
echo "    show_diff     = true" >> /etc/puppet/puppet.conf
echo "[agent]" >> /etc/puppet/puppet.conf
echo "    classfile = $statedir/classes.txt" >> /etc/puppet/puppet.conf
echo "    localconfig = $vardir/localconfig" >> /etc/puppet/puppet.conf
echo "    default_schedules = false" >> /etc/puppet/puppet.conf
echo "    report            = true" >> /etc/puppet/puppet.conf
echo "    pluginsync        = true" >> /etc/puppet/puppet.conf
echo "    masterport        = 8140" >> /etc/puppet/puppet.conf
echo "    certname          = $hostname" >> /etc/puppet/puppet.conf
echo "    server            = $server" >> /etc/puppet/puppet.conf
echo "    listen            = true" >> /etc/puppet/puppet.conf
echo "    splay             = false" >> /etc/puppet/puppet.conf
echo "    splaylimit        = 1800" >> /etc/puppet/puppet.conf
echo "    runinterval       = 1800" >> /etc/puppet/puppet.conf
echo "    noop              = false" >> /etc/puppet/puppet.conf
echo "    configtimeout     = 120" >> /etc/puppet/puppet.conf
echo "    usecacheonfailure = true" >> /etc/puppet/puppet.conf
