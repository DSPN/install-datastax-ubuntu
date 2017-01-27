#!/usr/bin/env bash

echo in configure_sparkmasterport.sh

file=/etc/opscenter/opscenterd.conf

date=$(date +%F)
backup="$file.$date"
cp $file $backup

echo "" >> $file
echo [spark] >> $file
echo "base_master_proxy_port = 17080" >> $file

