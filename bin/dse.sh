#!/usr/bin/env bash

echo "Running install-datastax/bin/dse.sh"

cloud_type=$1
seed_nodes_dns_names=$2
data_center_name=$3
opscenter_dns_name=$4
dcos_container_path=$5
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dse_log_path=$6
search_enabled=$7
analytics_enabled=$8
graph_enabled=$9

# Assuming only one seed is passed in for now
seed_node_dns_name=$seed_nodes_dns_names

seed_node_ip=""
while [ "${seed_node_ip}" == "" ]; do
  seed_node_ip=`getent hosts $seed_node_dns_name | awk '{ print $1 }'`
done  

opscenter_ip=""
while [ "${opscenter_ip}" == "" ]; do
  opscenter_ip=`getent hosts $opscenter_dns_name | awk '{ print $1 }'`
done  

node_broadcast_ip=`echo $(hostname -I) | cut -f 1 -d " "`
node_ip=`echo $(hostname -I) | cut -f 1 -d " "`

echo "Configuring nodes with the settings:"
echo cloud_type \'$cloud_type\'
echo data_center_name \'$data_center_name\'
echo seed_node_ip \'$seed_node_ip\'
echo node_broadcast_ip \'$node_broadcast_ip\'
echo node_ip \'$node_ip\'
echo opscenter_ip \'$opscenter_ip\'
echo dcos_container_path \'$dcos_container_path\'
echo dse_log_path \'$dse_log_path\'
echo dse_search \'$search_enabled\'
echo dse_analytics \'$analytics_enabled\'
echo dse_graph \'$graph_enabled\'

#### Ok, now let's starting making changes to the system...

# OpsCenter uses iostat and Ubuntu 14.04 LTS doesn't seem to have it installed by default.
$TOOLS_DIR/dse/configure_cassandra_rackdc_properties.sh $cloud_type $data_center_name
$TOOLS_DIR/dse/configure_cassandra_yaml.sh $node_ip $node_broadcast_ip $seed_node_ip $cloud_type $dcos_container_path
$TOOLS_DIR/dse/configure_agent_address_yaml.sh $node_ip $node_broadcast_ip $opscenter_ip
$TOOLS_DIR/dse/configure_dse.sh $search_enabled $analytics_enabled $graph_enabled
$TOOLS_DIR/dse/configure_log.sh $dse_log_path 
$TOOLS_DIR/dse/start.sh

while true
do
  sleep 1000000
done
