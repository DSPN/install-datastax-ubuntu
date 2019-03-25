#!/usr/bin/env bash

end=100

# install extra packages
#
#killall -9 apt apt-get apt-key
#
#rm /var/lib/dpkg/lock
#rm /var/lib/apt/lists/lock
#rm /var/cache/apt/archives/lock
#
#dpkg --configure -a &
#dpkg_process_id=$!
#echo "dpkg_process_id $dpkg_process_id" 
#

# check for lock
echo -e "extra packages checking if dpkg is running after dpkg --configure -a, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done


#apt-get -y update &
#update_process_id=$!
#echo "update_process_id $update_process_id"


export DEBIAN_FRONTEND=noninteractive
apt-get -y install zip unzip python-pip jq sysstat

# check for lock
echo -e "extra pckages Checking if apt/dpkg running before pip, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done


# install requests pip pacakge
pip install requests

