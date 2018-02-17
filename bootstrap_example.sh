#!/usr/bin/env bash

set -ex

#set variables
CLUSTER_NAME=throttling_production
DC_NAME=THR1
CLOUD_TYPE_NAME=aws
OPSCENTER_IP=localhost
DNS_NAME=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
VOLUMES_FOR_RAID0=/dev/xvdb,/dev/xvdc
RAID0_DEVICE=/dev/md0
SOLR_ENABLED="0"

#ubuntu14 update
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y --install-recommends linux-generic-lts-xenial

#installing git
sudo apt-get install git -y

#installing python-pip & boto
sudo apt-get install python-pip -y
sudo pip install boto

#downloading DSE bootstrap scripts
git clone https://github.com/getjaco/install-datastax-ubuntu.git
cd install-datastax-ubuntu/bin
git checkout 5.1.6

#installing DSE, java8
sudo ./dse.sh $CLOUD_TYPE_NAME $DNS_NAME $DC_NAME $OPSCENTER_IP $CLUSTER_NAME $SOLR_ENABLED

#installing raid0
sudo ./dse-raid-setup.sh --disks /dev/xvdb,/dev/xvdc --raiddev /dev/md0 --update-fstab
