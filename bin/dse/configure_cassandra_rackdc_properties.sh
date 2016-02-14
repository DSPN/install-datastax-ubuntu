#!/usr/bin/env bash

dc="dc0"
rack="123"

file=/etc/dse/cassandra/cassandra-rackdc.properties

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:^\(dc\=\).*:dc\=$dc:" \
| sed -e "s:^\(rack\=\).*:rack\=$rack:" \
> $file.new

mv $file.new $file