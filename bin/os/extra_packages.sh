#!/usr/bin/env bash

end=150

# install extra packages
echo -e "Checking if apt/dpkg running, start: $(date +%r)"
#while ps -A | grep -e apt -e dpkg >/dev/null 2>&1; do sleep 10s; done;
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done
echo -e "No other procs: $(date +%r)"

#apt-get update
apt-get -y install zip unzip python-pip jq sysstat

# install requests pip pacakge
pip install requests
