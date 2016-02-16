#!/usr/bin/env bash

seed_node_public_ip=$1

./os/install_java.sh
./opscenter/install.sh

cat <</EOF >> /etc/opscenter/opscenterd.conf

[clusters]
add_cluster_timeout = 90
/EOF

./opscenter/start.sh

#./opscenter/manage_existing_cluster.sh $seed_node_public_ip
