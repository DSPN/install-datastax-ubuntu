#!/usr/bin/env bash

opscenter_broadcast_ip=$1

file="/etc/opscenter/opscenterd.conf"
echo "Adding the broadcast IP to opscenterd.conf"
echo "[agents]" >> $file
echo "reported_interface=$opscenter_broadcast_ip" >> $file
echo "" >> $file
