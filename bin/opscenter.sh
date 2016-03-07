#!/usr/bin/env bash

echo "Running install-datastax/bin/opscenter.sh"

seed_nodes_dns_names=$1

# Assuming only one seed is passed in for now
seed_node_dns_name=$seed_nodes_dns_names

# On AWS and Azure this gets the public IP.  On Google it resolves to a private IP that is globally routeable in GCP.
seed_node_ip=`dig +short $seed_node_dns_name`

echo "Configuring OpsCenter with the settings:"
echo seed_node_ip \'$seed_node_ip\'

./os/install_java.sh
./opscenter/install.sh
./opscenter/start.sh

echo "Waiting for OpsCenter and nodes to start..."
sleep 300
./opscenter/manage_existing_cluster.sh $seed_node_ip
