#!/usr/bin/env bash

set -e

max_solr_concurrency_per_core=$1
file=/etc/dse/dse.yaml

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:[# ]*\(max_solr_concurrency_per_core\:\).*:max_solr_concurrency_per_core\: $max_solr_concurrency_per_core:" \
> $file.new

mv $file.new $file

