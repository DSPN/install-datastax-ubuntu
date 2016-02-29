#!/usr/bin/env bash

echo "Running install-datastax/bin/opscenter.sh"

seed_nodes_dns_names=$1

# Assuming only one seed is passed in for now
seed_node_dns_name=$seed_node_dns_names
seed_node_public_ip=`dig +short $seed_node_dns_name | awk '{ print ; exit }'`

./os/install_java.sh
./opscenter/install.sh
./opscenter/start.sh

# Wait for OpsCenter to start
sleep 60
./opscenter/manage_existing_cluster.sh $seed_node_public_ip
