#!/usr/bin/env bash

node_ip=$1
node_broadcast_ip=$2
seed_node_public_ip=$3

seeds=$seed_node_public_ip
listen_address=$node_ip
broadcast_address=$node_broadcast_ip
rpc_address="0.0.0.0"
broadcast_rpc_address=$node_broadcast_ip

endpoint_snitch="GossipingPropertyFileSnitch"
num_tokens=64
data_file_directories="/mnt/data"
commitlog_directory="/mnt/commitlog"
saved_caches_directory="/mnt/saved_caches"
phi_convict_threshold=12
auto_bootstrap="false"

file=/etc/dse/cassandra/cassandra.yaml

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:\(.*- *seeds\:\).*:\1 \"$seeds\":" \
| sed -e "s:[# ]*\(listen_address\:\).*:listen_address\: $listen_address:" \
| sed -e "s:[# ]*\(broadcast_address\:\).*:broadcast_address\: $broadcast_address:" \
| sed -e "s:[# ]*\(rpc_address\:\).*:rpc_address\: $rpc_address:" \
| sed -e "s:[# ]*\(broadcast_rpc_address\:\).*:broadcast_rpc_address\: $broadcast_rpc_address:" \
| sed -e "s:.*\(endpoint_snitch\:\).*:endpoint_snitch\: $endpoint_snitch:" \
| sed -e "s:.*\(num_tokens\:\).*:\1 $num_tokens:" \
| sed -e "s:\(.*- \)/var/lib/cassandra/data.*:\1$data_file_directories:" \
| sed -e "s:.*\(commitlog_directory\:\).*:commitlog_directory\: $commitlog_directory:" \
| sed -e "s:.*\(saved_caches_directory\:\).*:saved_caches_directory\: $saved_caches_directory:" \
| sed -e "s:.*\(phi_convict_threshold\:\).*:phi_convict_threshold\: $phi_convict_threshold:" \
> $file.new

echo "auto_bootstrap: $auto_bootstrap" >> $file.new
echo "" >> $file.new

mv $file.new $file

# Owner was ending up as root which caused the backup service to fail
chown cassandra $file
chgrp cassandra $file
