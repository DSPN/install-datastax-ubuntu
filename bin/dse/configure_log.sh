#!/usr/bin/env bash

dse_log_path=$1/log
echo dse_log_path \'$dse_log_path\'

mkdir $dse_log_path
chown cassandra $dse_log_path
chgrp cassandra $dse_log_path

file=/etc/dse/cassandra/cassandra-env.sh

date=$(date +%F)
backup="$file.$date"
cp $file $backup

echo "" >> $file
echo "export CASSANDRA_LOG_DIR=$dse_log_path" >> $file

