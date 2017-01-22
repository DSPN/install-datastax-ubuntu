#!/usr/bin/env bash

dcos_opscenter_pv=$1
echo dcos_opscenter_pv \'$dcos_opscenter_pv\'

file=/etc/opscenter/logback.xml

# Create a log folder (log/opscenter) in persistent volume
mkdir -p $dcos_opscenter_pv/log/opscenter
chown -r opscenter $dcos_opscenter_pv/log/opscenter
chgrp -r opscenter $dcos_opscenter_pv/log/opscenter

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:<file>/var/log/opscenter/opscenterd.log</file>$:<file>$dcos_opscenter_pv/log/opscenter/opscenterd.log</file>:" \
> $file.new

mv $file.new $file

# Owner was ending up as root which caused the backup service to fail
chown opscenter $file
chgrp opscenter $file
