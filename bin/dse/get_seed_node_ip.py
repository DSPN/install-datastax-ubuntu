#! /usr/bin/env python

import sys
from boto import ec2, cloudformation
import boto.utils

def get_group_info(ec2conn, instance_id) :
    reservations = ec2conn.get_all_instances(instance_id)
    instance = [i for r in reservations for i in r.instances][0]
    if instance.tags.has_key('aws:autoscaling:groupName'):
        autoscale_group = instance.tags['aws:autoscaling:groupName']
        private_ip = instance.private_ip_address
        filters = {'tag:aws:autoscaling:groupName': '%s*' % autoscale_group, 'instance-state-name': 'running' }
        reservations = ec2conn.get_all_instances(filters=filters)
        instances = [i for r in reservations for i in r.instances]
        sorted_instances = sorted(instances, key=lambda i: (i.launch_time, i.id))
        first_node = sorted_instances[0]
        node_number = [si.id for si in sorted_instances].index(instance.id) + 1
        return private_ip, first_node, len(sorted_instances), autoscale_group, node_number
    else:
        return None

instance_data = boto.utils.get_instance_metadata()
instance_id = instance_data["instance-id"]

# connect to region of the current instance rather than default of us-east-1
zone = instance_data['placement']['availability-zone']
region_name = zone[:-1]

ec2conn = ec2.connect_to_region(region_name)
private_ip, first_node, nodes_total, stack_id, node_number = get_group_info(ec2conn, instance_id)

print "%s" % first_node.private_ip_address
