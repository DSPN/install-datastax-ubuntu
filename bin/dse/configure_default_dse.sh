#!/usr/bin/env bash

set -e

solr_enabled="0"
if [[ "$1" == "1" ]]; then
  solr_enabled=$1
fi
file=/etc/default/dse

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s=.*\(SOLR_ENABLED\=\).*=SOLR_ENABLED\=$solr_enabled=" \
> $file.new

mv $file.new $file
