#!/usr/bin/env bash

# looks like the agent creates an empty /var/lib/datastax-agent/conf/address.yaml when it starts for the first time
# given that, we're not going to worry about backing it up

file=/etc/dse/cassandra/cassandra.yaml

cd "$agent_conf_dir"
stomp_interface=$opscenter_public_ip
local_interface=$node_private_ip
agent_rpc_broadcast_address=$node_public_ip
agent_rpc_interface=$node_private_ip

cat address.yaml \
| sed -e "s:.*\(stomp_interface\:\).*:stomp_interface\: $stomp_interface:" \
| sed -e "s:.*\(local_interface\:\).*:hosts\: \[\"$local_interface\"\]:" \
| sed -e "s:.*\(hosts\:\).*:hosts\: \[\"$local_interface\"\]:" \
> address.yaml.new

if [ "x$(grep stomp_interface address.yaml)" == x ]; then echo "stomp_interface: $stomp_interface" >> address.yaml.new; fi
if [ "x$(grep hosts address.yaml)" == x ]; then echo "hosts: [\"$local_interface\"]" >> address.yaml.new; fi
