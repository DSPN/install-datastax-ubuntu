#!/usr/bin/env bash

echo "Running install-datastax/bin/opscenter.sh"

seed_nodes_dns_names=$1

# Assuming only one seed is passed in for now
seed_node_dns_name=$seed_node_dns_names

# On AWS and Azure this gets the public IP.  On Google it resolves to a private IP that is globally routeable in GCP.
seed_node_ip=`dig +short $seed_node_dns_name | awk '{ print ; exit }'`

./os/install_java.sh
./opscenter/install.sh
./opscenter/start.sh

# Wait for OpsCenter to start
sleep 60
./opscenter/manage_existing_cluster.sh $seed_public_ip
