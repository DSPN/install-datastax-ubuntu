#!/usr/bin/env bash
cloud_type=$1
node_ip=$2
echo "Starting DataStax Studio script"

echo "Update httpBindAddress"
file=$MESOS_SANDBOX/datastax-studio-1.0.2/conf/configuration.yaml

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:.*\(httpBindAddress\:\).*: httpBindAddress\: $node_ip:" \
> $file.new

mv $file.new $file

echo "Starting DataStax Studio"
$MESOS_SANDBOX/datastax-studio-1.0.2/bin/server.sh

