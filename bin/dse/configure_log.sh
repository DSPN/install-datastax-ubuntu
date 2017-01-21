#!/usr/bin/env bash

dse_log_path=$1
echo dse_log_path \'$dse_log_path\'

file=/etc/dse/cassandra/cassandra-env.sh

date=$(date +%F)
backup="$file.$date"
cp $file $backup

echo "" >> $file
echo "export CASSANDRA_LOG_DIR=$dse_log_path" >> $file

