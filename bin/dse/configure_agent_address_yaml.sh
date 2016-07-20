#!/usr/bin/env bash

node_ip=$1
node_broadcast_ip=$2
opscenter_ip=$3
# looks like the agent creates an empty /var/lib/datastax-agent/conf/address.yaml when it starts for the first time
# given that, we're not going to worry about backing it up

file=/var/lib/datastax-agent/conf/address.yaml

cat <</EOF > $file
stomp_interface: $opscenter_ip
agent_rpc_interface: $node_ip
agent_rpc_broadcast_address: $node_broadcast_ip
/EOF

chown cassandra $file
chgrp cassandra $file
