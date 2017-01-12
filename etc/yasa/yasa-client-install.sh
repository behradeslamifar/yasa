#!/bin/bash

# Oraganization Domain
DOMAIN=ioi.com

# user must be root
if [ "$(id -u)" != "0" ]
then
	echo "Please run script with root user ..... failed"
	exit 1
else
	echo "Run as root user ..... pass"
fi

# check run in ubuntu or debian
if [ ! -z '$(lsb_release -a | grep -i "debian\|ubuntu\|mint" 2> /dev/null)' ]
then
	echo "Run on debian base linux ..... pass"
else
	echo "Only Debain and Ubuntu already supported ..... failed"
	exit 1
fi

# Check and Resolve dependency
# puppet facter
dpkg -l puppet facter 2>&1 > /dev/null

if [ "$?" == "0" ]
then
	echo "Required packages ..... pass"
else
	echo "Required packages ..... failed"
	echo "Install dependency packages ...."
	apt-get update && apt-get -y install puppet facter
	if [ "$?" == "1" ]
	then	
		echo "Installation failed. Please check your apt sources list and run script again"
		exit 1
	else
		echo "Required packages installed successfully"
	fi
fi

# config puppet client
if [ ! -d "/etc/puppet" ]
then
	echo "Puppet configuration ..... failed"
	echo "Puppet config file not exist. Please reinstall puppet package"
	exit 1
fi
read -p "Please enter your puppet server: " server
echo "path	/run" > /etc/puppet/auth.conf
echo "method 	save" >> /etc/puppet/auth.conf
echo "auth	any" >> /etc/puppet/auth.conf
echo "allow	$server" >> /etc/puppet/auth.conf
echo "auth.conf file ..... pass"

hostname=$(hostname -f | grep "[a-zA-Z0-9]\+\.$DOMAIN$")
if [ -z "$hostname" ]
then
	echo $(hostname).$HOSTNAME > /etc/hostname
	hostname -F /etc/hostname
	echo "Hostname corrction ..... pass"
fi

[ -f /etc/puppet/puppet.conf ] && mv /etc/puppet/puppet.conf /etc/puppet/puppet.conf.$(date +"%y%m%d-%H%M")
cat <<EOF > /etc/puppet/puppet.conf
    vardir = /var/lib/puppet
    logdir = /var/log/puppet
    rundir = /var/run/puppet
    ssldir = /var/lib/puppet/ssl
[agent]
    default_schedules = false
    report            = true
    pluginsync        = true
    masterport        = 8140
    certname          = $hostname
    server            = $server
    listen            = true
    splay             = false
    splaylimit        = 1800
    runinterval       = 1800
    noop              = false
    configtimeout     = 120
    usecacheonfailure = true
EOF

echo "Puppet agent configuration ..... pass"

service puppet restart
if [ "$?" == "0" ]
then
	echo "Restart puppet agent ..... pass"
else
	echo "Restart puppet agent ..... failed"
	echo "Check puppet configuration manualy"
	exit 1
fi

exit 0
