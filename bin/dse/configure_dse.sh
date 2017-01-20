#!/usr/bin/env bash

search_enabled=$1
analytics_enabled=$2
graph_enabled=$3

cloud_type=DCOS

echo in configure_dse cloud_type = $cloud_type

echo dse_search \'$search_enabled\'
echo dse_analytics \'$analytics_enabled\'
echo dse_graph \'$graph_enabled\'


file=/etc/default/dse

date=$(date +%F)
backup="$file.$date"
cp $file $backup

if $search_enabled; then
  search_flag=1
else
  search_flag=0
fi

if $analytics_enabled; then
  analytics_flag=1
else
  analytics_flag=0
fi

if $graph_enabled; then
  graph_flag=1
else
  graph_flag=0
fi

cat $file \
| sed -e "s:.*\(SOLR_ENABLED\=\).*:SOLR_ENABLED\=$search_flag:" \
| sed -e "s:.*\(SPARK_ENABLED\=\).*:SPARK_ENABLED\=$analytics_flag:" \
| sed -e "s:.*\(GRAPH_ENABLED\=\).*:GRAPH_ENABLED\=$graph_flag:" \
> $file.new

mv $file.new $file

# Change owner of the updated dse file back to user cassandra
chown cassandra $file
chgrp cassandra $file
