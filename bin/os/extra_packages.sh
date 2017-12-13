#!/usr/bin/env bash

# install extra packages
echo -e "Checking for dpkg lock, start: $(date +%r)"
while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 1s; done;
echo -e "Lock released: $(date +%r)"

apt-get update
apt-get -y install unzip python-pip jq

# install requests pip pacakge
pip install requests
