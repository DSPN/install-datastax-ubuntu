#!/usr/bin/env bash

seed_node_public_ip="13.94.43.68"

./os/install_java.sh

./opscenter/install.sh
./opscenter/start.sh
./opscenter/manage_existing_cluster.sh $seed_node_public_ip
