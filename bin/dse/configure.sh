#!/usr/bin/env bash

echo $(basename "$0") "$@"
data_center_name=$1
seed_node_public_ip=$2
opscenter_public_ip=$3
node_public_ip=$4
node_private_ip=$5

#azure, gcp or aws
cloud_type=$6

#Make sure file systems were built
data_file_directories="/mnt/cassandra/data"
commitlog_directory="/mnt/cassandra/commitlog"
saved_caches_directory="/mnt/cassandra/saved_caches"

if [ -n $data_center_name ]; then		data_center_name=`printf '%s' 'data_center_name: ' >&2; read val; echo $val;`; fi
if [ -n $seed_node_public_ip ]; then	seed_node_public_ip=$default_seed_node_public_ip; fi
if [ -n $opscenter_public_ip ]; then 	opscenter_public_ip=$default_opscenter_public_ip; fi
if [ -n $node_public_ip ]; then 		node_public_ip=`curl --max-time 50000 --retry 12 --retry-delay 50000 -s 'http://checkip.dyndns.org' | sed 's/.*Current IP Address: \([0-9\.]*\).*/\1/g'`; fi
if [ -n $node_private_ip ]; then		node_private_ip=`echo $(hostname -I)`; fi

echo ''
echo data_center_name \'$data_center_name\'
echo seed_node_public_ip \'$seed_node_public_ip\'
echo opscenter_public_ip \'$opscenter_public_ip\'
echo node_public_ip \'$node_public_ip\'
echo node_private_ip \'$node_private_ip\'
