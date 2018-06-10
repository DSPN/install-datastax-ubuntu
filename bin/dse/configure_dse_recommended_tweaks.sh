#!/bin/bash

set -e

sudo sysctl -w \
net.ipv4.tcp_keepalive_time=60 \
net.ipv4.tcp_keepalive_probes=3 \
net.ipv4.tcp_keepalive_intvl=10 \
net.core.rmem_max=16777216 \
net.core.wmem_max=16777216 \
net.core.rmem_default=16777216 \
net.core.wmem_default=16777216 \
net.core.optmem_max=40960 \
net.ipv4.tcp_rmem="4096 87380 16777216" \
vm.min_free_kbytes=1048576 \
vm.nr_overcommit_hugepages=0 \
vm.max_map_count=1048575

sudo swapoff --all
echo never | sudo tee /sys/kernel/mm/transparent_hugepage/defrag
echo 0 | sudo tee /proc/sys/vm/zone_reclaim_mode

for CPUFREQ in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
do
  [ -f $CPUFREQ ] || continue
  echo -n performance > $CPUFREQ
done
