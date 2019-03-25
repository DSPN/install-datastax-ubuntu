#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

# install extra packages
echo -e "Checking if apt/dpkg running, start: $(date +%r)"
pkill -9  apt
killall -9 apt apt-get apt-key
#
rm /var/lib/dpkg/lock
rm /var/lib/apt/lists/lock
rm /var/cache/apt/archives/lock
#
dpkg --configure -a &
dpkg_process_id=$!
echo "dpkg_process_id $dpkg_process_id"
echo -e "No other procs: $(date +%r)"

apt-get update
apt-get -y install zip unzip python-pip jq sysstat

# install requests pip pacakge
pip install requests
