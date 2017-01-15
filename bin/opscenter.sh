#!/usr/bin/env bash

echo "Running install-datastax/bin/opscenter.sh"

cloud_type=$1
seed_nodes_dns_names=$2
TOOLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get curl package
apt-get -y update
apt-get -y install sudo
apt-get -y install curl

# Assuming only one seed is passed in for now
seed_node_dns_name=$seed_nodes_dns_names

# On GKE we resolve to a private IP.
# On AWS and Azure this gets the public IP.
# On GCE it resolves to a private IP that is globally routeable in GCE.
if [[ $cloud_type == "gke" ]]; then
  seed_node_ip=`getent hosts $seed_node_dns_name | awk '{ print $1w }'`
elif [[ $cloud_type == "DCOS" ]]; then
  opscenter_ip=""
  while [ "${opscenter_ip}" == "" ]; do
    opscenter_ip=`getent hosts $opscenter_dns_name | awk '{ print $1 }'`
  done  
  seed_node_ip=""
  while [ "${seed_node_ip}" == "" ]; do
    seed_node_ip=`getent hosts $seed_node_dns_name | awk '{ print $1w }'`
  done  
elif [[ $cloud_type == "gce" ]]; then
  # If the IP isn't up yet it will resolve to "" on GCE
  seed_node_ip=""
  while [ "${seed_node_ip}" == "" ]; do
    seed_node_ip=`dig +short $seed_node_dns_name`
  done
elif [[ $cloud_type == "azure" ]]; then
  # If the IP isn't up yet it will resolve to 255.255.255.255 on Azure
  seed_node_ip="255.255.255.255"
  while [ "${seed_node_ip}" == "255.255.255.255" ]; do
    seed_node_ip=`dig +short $seed_node_dns_name`
  done
elif [[ $cloud_type == "aws" ]]; then
  # If the IP isn't up yet it will resolve to "" on AWS?
  seed_node_ip=""
  while [ "${seed_node_ip}" == "" ]; do
    seed_node_ip=`dig +short $seed_node_dns_name`
  done
fi

echo "Configuring OpsCenter with the settings:"
echo cloud_type \'$cloud_type\'
echo seed_node_ip \'$seed_node_ip\'
echo opscenter_ip \'$opscenter_ip\'

if [[ $cloud_type == "azure" ]]; then
  $TOOLS_DIR/os/set_tcp_keepalive_time.sh
fi

$TOOLS_DIR/os/install_java.sh
$TOOLS_DIR/opscenter/install.sh $cloud_type

if [[ $cloud_type == "azure" ]]; then
  opscenter_broadcast_ip=`curl --retry 10 icanhazip.com`
  $TOOLS_DIR/opscenter/configure_opscenterd_conf.sh $opscenter_broadcast_ip
fi

echo "Starting OpsCenter..."
$TOOLS_DIR/opscenter/start.sh

echo "Waiting for OpsCenter to start..."
sleep 60

echo "Connecting OpsCenter to the cluster..."
$TOOLS_DIR/opscenter/manage_existing_cluster.sh $seed_node_ip

echo "Changing the keyspace from SimpleStrategy to NetworkTopologyStrategy."
$TOOLS_DIR/opscenter/configure_opscenter_keyspace.sh

echo "Starting DataStax Studio"
$TOOLS_DIR/opscenter/start_datastax_studio.sh $cloud_type $opscenter_ip

while true
do
  sleep 1
done
