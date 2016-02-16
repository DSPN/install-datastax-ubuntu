#!/usr/bin/env bash

seed_node_public_ip=$1

./os/install_java.sh

./opscenter/install.sh
./opscenter/start.sh

# going to try setting [clusters] add_cluster_timeout to 90 seconds before running this
#./opscenter/manage_existing_cluster.sh $seed_node_public_ip
