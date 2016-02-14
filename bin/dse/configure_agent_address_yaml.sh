#!/usr/bin/env bash

node_private_ip=$1
node_public_ip=$2
$opscenter_public_ip=$3

# looks like the agent creates an empty /var/lib/datastax-agent/conf/address.yaml when it starts for the first time
# given that, we're not going to worry about backing it up

file=/var/lib/datastax-agent/conf/address.yaml

cat <</EOF > $file
stomp_interface: $opscenter_public_ip
local_interface: $node_private_ip
agent_rpc_interface: $node_private_ip
agent_rpc_broadcast_address: $node_public_ip
/EOF
