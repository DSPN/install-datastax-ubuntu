#!/usr/bin/env bash

set -ex

#set variables
CLUSTER_NAME=jaco-elements-test
DC_NAME=DC1
CLOUD_TYPE_NAME=aws
OPSCENTER_IP=localhost
DNS_NAME=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
RAID0_DEVICE=/dev/md0
SOLR_ENABLED="1"

#ubuntu update
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo apt-get install -y --install-recommends linux-generic-lts-xenial

#installing git & jq (required for parsing lsblk json)
sudo apt-get install git jq -y

#installing python-pip & boto
sudo apt-get install python-pip -y
sudo pip install boto

#downloading DSE bootstrap scripts
git clone https://github.com/getjaco/install-datastax-ubuntu.git
cd install-datastax-ubuntu/bin
git checkout 5.1.0

#installing newer lsblk with --json
VOLUMES_FOR_RAID0=`lsblk --json | jq '.blockdevices | .[] | select(.children | length == 0) | .name' | sed s/\"//g | xargs -I{} echo /dev/{} | cat |  paste -d, - -`

#installing raid0
sudo ./dse-raid-setup.sh --disks $VOLUMES_FOR_RAID0 --raiddev /dev/md0 --update-fstab

#installing DSE, java8
sudo ./dse.sh $CLOUD_TYPE_NAME $DNS_NAME $DC_NAME $OPSCENTER_IP $CLUSTER_NAME $SOLR_ENABLED
