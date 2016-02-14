#!/usr/bin/env bash

node_private_ip=$1

seeds="$seed_node_public_ip"
listen_address=$node_private_ip
broadcast_address=$node_public_ip
rpc_address=$node_private_ip
broadcast_rpc_address=$node_public_ip

endpoint_snitch="GossipingPropertyFileSnitch"
num_tokens=64
data_file_directories="/mnt"
phi_convict_threshold=12

file=/etc/dse/cassandra/cassandra.yaml

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat $file \
| sed -e "s:\(.*- *seeds\:\).*:\1 \"$seeds\":" \
| sed -e "s:[# ]*\(listen_address\:\).*:listen_address\: $listen_address:" \
| sed -e "s:[# ]*\(broadcast_address\:\).*:broadcast_address\: $broadcast_address:" \
| sed -e "s:[# ]*\(rpc_address\:\).*:rpc_address\: $rpc_address:" \
| sed -e "s:[# ]*\(broadcast_rpc_address\:\).*:broadcast_rpc_address\: $broadcast_rpc_address:" \
| sed -e "s:.*\(endpoint_snitch\:\).*:endpoint_snitch\: $endpoint_snitch:" \
| sed -e "s:.*\(num_tokens\:\).*:\1 $num_tokens:" \
| sed -e "s:\(.*- \)/var/lib/cassandra/data.*:\1$data_file_directories:" \
| sed -e "s:.*\(commitlog_directory\:\).*:commitlog_directory\: $commitlog_directory:" \
| sed -e "s:.*\(saved_caches_directory\:\).*:saved_caches_directory\: $saved_caches_directory:" \
| sed -e "s:.*\(concurrent_reads\:\).*:concurrent_reads\: $concurrent_reads:" \
| sed -e "s:.*\(concurrent_writes\:\).*:concurrent_writes\: $concurrent_writes:" \
| sed -e "s:.*\(memtable_flush_writers\:\).*:memtable_flush_writers\: $memtable_flush_writers:" \
| sed -e "s:.*\(concurrent_compactors\:\).*:concurrent_compactors\: $concurrent_compactors:" \
| sed -e "s:.*\(compaction_throughput_mb_per_sec\:\).*:compaction_throughput_mb_per_sec\: $compaction_throughput_mb_per_sec:" \
| sed -e "s:.*\(phi_convict_threshold\:\).*:phi_convict_threshold\: $phi_convict_threshold:" \
| sed -e "s:.*\(inter_dc_stream_throughput_outbound_megabits_per_sec\:\).*:inter_dc_stream_throughput_outbound_megabits_per_sec\: $inter_dc_stream_throughput_outbound_megabits_per_sec:" \
| sed -e "s:.*\(write_request_timeout_in_ms\:\).*:write_request_timeout_in_ms\: $write_request_timeout_in_ms:" \
> $file.new

mv $file.new $file
