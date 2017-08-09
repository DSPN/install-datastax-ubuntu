#!/bin/bash -e

#set variables
DC_NAME=FE1
CLOUD_TYPE_NAME=aws
DNS_NAME=localhost
VOLUMES_FOR_RAID0=/dev/xvdb,/dev/xvdc
RAID0_DEVICE=/dev/md0

#ubuntu14 update
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y --install-recommends linux-generic-lts-xenial

#installing git
sudo apt-get install git -y

#downloading DSE bootstrap scripts
git clone https://github.com/getjaco/install-datastax-ubuntu.git
cd install-datastax-ubuntu/bin

#installing DSE, java8
sudo ./dse.sh $CLOUD_TYPE_NAME $DNS_NAME $DC_NAME

#installing raid0
sudo ./dse-raid-setup.sh --disks /dev/xvdb,/dev/xvdc --raiddev /dev/md0 --update-fsta
