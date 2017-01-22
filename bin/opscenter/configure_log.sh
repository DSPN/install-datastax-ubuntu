#!/usr/bin/env bash

dse_opscenter_pv=$1
echo dse_opscenter_pv \'$dse_opscenter_pv\'

file=/etc/opscenter/logback.xml

# Create a log folder (log/opscenter) in persistent volume
mkdir -p $dse_opscenter_pv/log/opscenter
chown -r opscenter $dse_opscenter_pv/log/opscenter
chgrp -r opscenter $dse_opscenter_pv/log/opscenter

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:<file>/var/log/opscenter/opscenterd.log</file>$:<file>$dse_opscenter_pv/log/opscenter/opscenterd.log</file>:" \
> $file.new

mv $file.new $file
