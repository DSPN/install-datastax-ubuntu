#!/usr/bin/env bash

seed_node_public_ip=$1

./os/install_java.sh
./opscenter/install.sh
./opscenter/start.sh

# wait for OpsCenter to start
sleep 60
./opscenter/manage_existing_cluster.sh $seed_node_public_ip
