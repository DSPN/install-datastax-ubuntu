#!/usr/bin/env bash

# hard coding some things for now...

# want to support azure, aws and google
cloud_type="azure"
data_center_name="dc0"

# just going to hard code a private ip for now...
# This is the lowest usable ip in our range.
seed_node_public_ip="10.0.0.4"
opscenter_public_ip=""

# probably ought to use the appropriate metadata service instead of this
node_public_ip=`curl --max-time 50000 --retry 12 --retry-delay 50000 -s 'http://checkip.dyndns.org' | sed 's/.*Current IP Address: \([0-9\.]*\).*/\1/g'`

node_private_ip=`echo $(hostname -I)`

echo "Configuring nodes with the settings:"
echo cloud_type \'$cloud_type\'
echo data_center_name \'$data_center_name\'
echo seed_node_public_ip \'$seed_node_public_ip\'
echo opscenter_public_ip \'$opscenter_public_ip\'
echo node_public_ip \'$node_public_ip\'
echo node_private_ip \'$node_private_ip\'
