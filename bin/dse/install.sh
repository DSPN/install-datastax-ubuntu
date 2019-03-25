#!/usr/bin/env bash

cloud_type=$1

# Set DSE, OpsC versions.
# Overidable by setting env var in calling template,
# eg: export OPSC_VERSION='6.1.0'

dse_version=5.1.9-1
opscenter_version=6.5.0

if [ -z "$OPSC_VERSION" ]
then
  echo "env \$OPSC_VERSION is not set, using default: $opscenter_version"
else
  echo "env \$OPSC_VERSION is set: $OPSC_VERSION overiding default"
  opscenter_version=$OPSC_VERSION
fi

if [ -z "$DSE_VERSION" ]
then
  echo "env \$DSE_VERSION is not set, using default: $dse_version"
else
  echo "env \$DSE_VERSION is set: $DSE_VERSION overiding default"
  dse_version=$DSE_VERSION
fi

echo "Installing DataStax Enterprise"

echo "Adding the DataStax repository"
if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  echo "deb http://datastax%40google.com:8GdeeVT2s7zi@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
elif [[ $cloud_type == "azure" ]]; then
  echo "deb http://datastax%40microsoft.com:3A7vadPHbNT@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
elif [[ $cloud_type == "aws" ]]; then
  echo "deb http://datastax%40amazon.com:A8ePXn%5EHH0%260@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
elif [[ $cloud_type == "oracle" ]] || [[ $cloud_type == "bmc" ]]; then
  echo "deb http://datastax%40oracle.com:*9En9HH4j%5Ep4@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
else
  echo "deb http://datastax%40clouddev.com:CJ9o%21wOlDX1a@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
fi

export DEBIAN_FRONTEND=noninteractive
end=150
#
#
killall -9 apt apt-get apt-key
#
rm /var/lib/dpkg/lock
rm /var/lib/apt/lists/lock
rm /var/cache/apt/archives/lock
#
dpkg --configure -a &
dpkg_process_id=$!
echo "dpkg_process_id $dpkg_process_id"
#

#

# check for lock
echo -e "node Checking if apt/dpkg running before repo_key, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done
#
export DEBIAN_FRONTEND=noninteractive
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
#
# check for lock
echo -e "node Checking if apt/dpkg running after repo_key, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done

echo "before apt-get update $output"
#
export DEBIAN_FRONTEND=noninteractive
apt-get -y update &
update_process_id=$!
echo "update_process_id $update_process_id"
#

# check for lock
echo -e "node Checking if apt/dpkg running after update, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done


echo "Running apt-get install dse"
export DEBIAN_FRONTEND=noninteractive
apt-get -y install dse-full=$dse_version dse=$dse_version dse-demos=$dse_version dse-libsolr=$dse_version dse-libtomcat=$dse_version dse-liblog4j=$dse_version dse-libcassandra=$dse_version dse-libspark=$dse_version dse-libhadoop2-client-native=$dse_version dse-libgraph=$dse_version dse-libhadoop2-client=$dse_version

# check for lock
echo -e "Checking if apt/dpkg running after install dse-full, start: $(date +%r)"
while [ $SECONDS -lt $end ]; do
   output=`ps -A | grep -e apt -e dpkg`
   if [ -z "$output" ]
   then
     break;
   fi
done

echo "before agent $output"

echo "Running apt-get install datastax-agent"
export DEBIAN_FRONTEND=noninteractive
apt-get -y install datastax-agent=$opscenter_version

# The install of dse creates a cassandra user, so now we can do this:
chown cassandra /mnt
chgrp cassandra /mnt

#
killall -9 apt apt-get apt-key
#
rm /var/lib/dpkg/lock
rm /var/lib/apt/lists/lock
rm /var/cache/apt/archives/lock
#
dpkg --configure -a &
dpkg_process_id=$!
echo "dpkg_process_id $dpkg_process_id"
#
