#!/usr/bin/env bash

if [ $cloud_type == "azure" ]; then
	# Determine Fault Domain used to create the Rack name to create rackdc.properties
	# to allow cassandra to place each of 3 replicas on separate fault domains
	fault_domain=$(curl --max-time 50000 --retry 12 --retry-delay 50000 http://169.254.169.254/metadata/v1/InstanceInfo -s -S | sed -e 's/.*"FD":"\([^"]*\)".*/\1/')
	if [ ! "$fault_domain" ]; then
		echo Unable to retrieve Instance Fault Domain from instance metadata server 1>&2
		exit 99
	fi
	echo Fault Domain: "$fault_domain"
	rack="FD$fault_domain"
fi
if [ $cloud_type == "aws" ]; then
	availability_zone=$( curl --max-time 50000 --retry 12 --retry-delay 50000 http://169.254.169.254/latest/meta-data/placement/availability-zone -s -S )
	if [ ! "$availability_zone" ]; then
		echo Unable to retrieve Instance Availability Zone from instance metadata server 1>&2
		exit 99
	fi
	echo Availability Zone: "$availability_zone"
	rack=$(echo $availability_zone | sed -e 's/-/_/g')
fi
echo rack: $rack
