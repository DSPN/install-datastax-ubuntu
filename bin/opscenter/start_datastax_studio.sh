#!/usr/bin/env bash
node_ip=$1
echo "Starting DataStax Studio script"

echo "Update httpBindAddress"
file=$MESOS_SANDBOX/datastax-studio-1.0.2/conf/configuration.yaml

date=$(date +%F)
backup="$file.$date"
cp $file $backup

> $file.new

mv $file.new $file

echo "Starting DataStax Studio"
$MESOS_SANDBOX/datastax-studio-1.0.2/bin/server.sh

