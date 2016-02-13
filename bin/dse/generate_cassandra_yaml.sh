#!/usr/bin/env bash

#
# Generate cassandra.yaml
#
cluster_name='Cluster'
seeds="$seed_node_public_ip"
listen_address=$node_private_ip
broadcast_address=$node_public_ip
rpc_address=$node_private_ip
broadcast_rpc_address=$node_public_ip
endpoint_snitch="GossipingPropertyFileSnitch"
num_tokens=64

concurrent_reads=64
concurrent_writes=64
memtable_flush_writers=3
concurrent_compactors=2
compaction_throughput_mb_per_sec=0
commitlog_segment_size_in_mb=64
compaction_throughput_mb_per_sec=100
phi_convict_threshold=12
inter_dc_stream_throughput_outbound_megabits_per_sec=100
write_request_timeout_in_ms=3000

# TODO: Change the "-" substitutions to a  multi-line sed pattern substitution.
cat cassandra.yaml \
| sed -e "s:.*\(cluster_name\:\).*:cluster_name\: \'$cluster_name\':" \
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
> cassandra.yaml.new
(set -x; chown cassandra:cassandra cassandra.yaml.new)
(set -x; diff cassandra.yaml cassandra.yaml.new)
(set -x; mv -f cassandra.yaml.new cassandra.yaml )
