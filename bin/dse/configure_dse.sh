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

if [ $search_enabled -eq "true" ]; then
  cat $file \
  | sed -e "s:.*\(SOLR_ENABLED\=\).*:SOLR_ENABLED\=1:" \
  > $file.new
else
  cat $file \
  | sed -e "s:.*\(SOLR_ENABLED\=\).*:SOLR_ENABLED\=0:" \
  > $file.new
fi

if [ $analytics_enabled -eq "true" ]; then
  cat $file.new \
  | sed -e "s:.*\(SPARK_ENABLED\=\).*:SPARK_ENABLED\=1:" \
  > $file.new
else
  cat $file.new \
  | sed -e "s:.*\(SPARK_ENABLED\=\).*:SPARK_ENABLED\=0:" \
  > $file.new
fi

if [ $graph_enabled -eq "true" ]; then
  cat $file.new \
  | sed -e "s:.*\(GRAPH_ENABLED\=\).*:GRAPH_ENABLED\=1:" \
  > $file.new
else
  cat $file.new \
  | sed -e "s:.*\(GRAPH_ENABLED\=\).*:GRAPH_ENABLED\=0:" \
  > $file.new
fi

mv $file.new $file

# Change owner of the updated dse file back to user cassandra
chown cassandra $file
chgrp cassandra $file
