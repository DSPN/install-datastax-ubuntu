#!/usr/bin/env bash

cloud_type=$1 #azure, gcp or aws
data_center_name=$2
seed_node_public_ip=$3
opscenter_public_ip=$4

# probably ought to use the appropriate metadata service instead of this
node_public_ip=`curl --max-time 50000 --retry 12 --retry-delay 50000 -s 'http://checkip.dyndns.org' | sed 's/.*Current IP Address: \([0-9\.]*\).*/\1/g'`

node_private_ip=`echo $(hostname -I)`

echo "Configuring nodes with the settings:"
echo data_center_name \'$data_center_name\'
echo seed_node_public_ip \'$seed_node_public_ip\'
echo opscenter_public_ip \'$opscenter_public_ip\'
echo node_public_ip \'$node_public_ip\'
echo node_private_ip \'$node_private_ip\'
