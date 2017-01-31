#!/usr/bin/env bash

cloud_type="$1"
dc="$2"
echo CLOUD_type = $cloud_type 1>&2
rack="rack1"

file=/etc/dse/cassandra/cassandra-rackdc.properties

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:^\(dc\=\).*:dc\=$dc:" \
| sed -e "s:^\(rack\=\).*:rack\=$rack:" \
| sed -e "s:^\(prefer_local\=\).*:rack\=true:" \
> $file.new

mv $file.new $file
