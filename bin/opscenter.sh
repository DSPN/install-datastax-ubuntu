#!/usr/bin/env bash

echo "Running install-datastax/bin/opscenter.sh"

cloud_type=$1
seed_nodes_dns_names=$2

# Assuming only one seed is passed in for now
seed_node_dns_name=$seed_nodes_dns_names

# Seed Resolution -----
# On GKE we resolve to a private IP.
# On AWS and Azure this gets the public IP.
# On GCE it resolves to a private IP that is globally routeable in GCE.
if [[ $cloud_type == "gke" ]]; then
  seed_node_ip=`getent hosts $seed_node_dns_name | awk '{ print $1w }'`
else
  seed_node_ip=`dig +short $seed_node_dns_name`
fi

echo "Configuring OpsCenter with the settings:"
echo cloud_type \'$cloud_type\'
echo seed_node_ip \'$seed_node_ip\'

if [[ $cloud_type == "azure" ]]; then
  ./os/set_tcp_keepalive_time.sh
fi

./os/install_java.sh
./opscenter/install.sh $cloud_type

if [[ $cloud_type == "azure" ]]; then
  opscenter_broadcast_ip=`curl --retry 10 icanhazip.com`
  ./opscenter/configure_opscenterd_conf.sh $opscenter_broadcast_ip
fi

./opscenter/start.sh

echo "Waiting for OpsCenter to start..."
sleep 100
./opscenter/manage_existing_cluster.sh $seed_node_ip
