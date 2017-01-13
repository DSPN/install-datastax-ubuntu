#!/usr/bin/env bash

echo "Running install-datastax/bin/dse.sh"

cloud_type=$1
seed_nodes_dns_names=$2
data_center_name=$3
opscenter_dns_name=$4
dcos_container_path=$5
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
if [[ $cloud_type == "gke" ]] || [[ $cloud_type == "DCOS" ]]; then
  seed_node_ip=`getent hosts $seed_node_dns_name | awk '{ print $1 }'`
  opscenter_ip=`getent hosts $opscenter_dns_name | awk '{ print $1 }'`
elif [[ $cloud_type == "gce" ]]; then
  # If the IP isn't up yet it will resolve to "" on GCE

  seed_node_ip=""
  while [ "${seed_node_ip}" == "" ]; do
    seed_node_ip=`dig +short $seed_node_dns_name`
  done

  opscenter_ip=""
  while [ "${opscenter_ip}" == "" ]; do
    opscenter_ip=`dig +short $opscenter_dns_name`
  done
elif [[ $cloud_type == "azure" ]]; then
  # If the IP isn't up yet it will resolve to 255.255.255.255 on Azure

  seed_node_ip="255.255.255.255"
  while [ "${seed_node_ip}" == "255.255.255.255" ]; do
    seed_node_ip=`dig +short $seed_node_dns_name`
  done

  opscenter_ip="255.255.255.255"
  while [ "${opscenter_ip}" == "255.255.255.255" ]; do
    opscenter_ip=`dig +short $opscenter_dns_name`
  done
elif [[ $cloud_type == "aws" ]]; then
  seed_node_ip=`getent hosts $seed_node_dns_name | awk '{ print $1 }'`
  opscenter_ip=`getent hosts $opscenter_dns_name | awk '{ print $1 }'`
fi

if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  # On Google private IPs are globally routable within GCE
  # We've also been seeing issues using the public ones for broadcast.
  # So, we're just going to use the private for everything.
  # We're still trying to figure out GKE, but only supporting 1 DC for now, so this ought to work.
  node_broadcast_ip=`echo $(hostname -I)`
  node_ip=`echo $(hostname -I)`
else
  node_broadcast_ip=`curl --retry 10 icanhazip.com`
  node_ip=`echo $(hostname -I)`
fi

echo "Configuring nodes with the settings:"
echo cloud_type \'$cloud_type\'
echo data_center_name \'$data_center_name\'
echo seed_node_ip \'$seed_node_ip\'
echo node_broadcast_ip \'$node_broadcast_ip\'
echo node_ip \'$node_ip\'
echo opscenter_ip \'$opscenter_ip\'

#### Ok, now let's starting making changes to the system...

$TOOLS_DIR/os/install_java.sh

# OpsCenter uses iostat and Ubuntu 14.04 LTS doesn't seem to have it installed by default.
sudo apt-get -y install sysstat
$TOOLS_DIR/dse/install.sh $cloud_type $dcos_container_path
$TOOLS_DIR/dse/configure_cassandra_rackdc_properties.sh $cloud_type $data_center_name
$TOOLS_DIR/dse/configure_cassandra_yaml.sh $node_ip $node_broadcast_ip $seed_node_ip $cloud_type $dcos_container_path
$TOOLS_DIR/dse/configure_agent_address_yaml.sh $node_ip $node_broadcast_ip $opscenter_ip
$TOOLS_DIR/dse/start.sh

# It looks like DSE might be setting the keepalive to 300.  Need to confirm.
if [[ $cloud_type == "azure" ]]; then
  $TOOLS_DIR/os/set_tcp_keepalive_time.sh
fi

while true
do
  sleep 1
done
