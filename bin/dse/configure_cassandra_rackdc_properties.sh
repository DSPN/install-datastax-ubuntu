#!/usr/bin/env bash

#
# generate cassandra-rackdc.properties.new
#
dc=$data_center_name
rack=$rack
cat cassandra-rackdc.properties \
| sed -e "s:^\(dc\=\).*:dc\=$dc:" \
| sed -e "s:^\(rack\=\).*:rack\=$rack:" \
> cassandra-rackdc.properties.new
(set -x; chown cassandra:cassandra cassandra-rackdc.properties.new)
(set -x; diff cassandra-rackdc.properties cassandra-rackdc.properties.new)
(set -x; mv -f cassandra-rackdc.properties.new cassandra-rackdc.properties )

