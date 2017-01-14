#!/usr/bin/env bash

cloud_type=DCOS

echo in configure_dse cloud_type = $cloud_type

file=/etc/default/dse

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:.*\(SOLR_ENABLED\=\).*:SOLR_ENABLED\=1:" \
| sed -e "s:.*\(SPARK_ENABLED\=\).*:SPARK_ENABLED\=1:" \
| sed -e "s:.*\(GRAPH_ENABLED\=\).*:GRAPH_ENABLED\=1:" \
> $file.new

mv $file.new $file

# Change owner of the updated dse file back to user cassandra
chown cassandra $file
chgrp cassandra $file
