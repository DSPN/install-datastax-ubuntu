#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

# install extra packages
echo -e "Checking if apt/dpkg running, start: $(date +%r)"
#while ps -A | grep -e apt -e dpkg >/dev/null 2>&1; do sleep 10s; done;
#while true; do
#  STATUS=`ps -A | grep -e apt -e dpkg`
#
#  if [ -z "$STATUS" ]; then
#    break
#  else
#    echo "" &> /dev/null
#  fi

#  sleep 1200

#done
killall -9 apt apt-get apt-key apt.systemd.dai
echo -e "No other procs: $(date +%r)"

apt-get update
apt-get -y install zip unzip python-pip jq sysstat

# install requests pip pacakge
pip install requests
