#!/usr/bin/env bash

seed_node_ip=$1

sudo tee config.json > /dev/null <<EOF
{
  "cassandra": {
    "seed_hosts": "$seed_node_ip"
  },
  "cassandra_metrics": {},
  "jmx": {
    "port": "7199"
  }
}
EOF

output="temp"
while [ "${output}" != "\"Test_Cluster\"" ]; do
    output=`curl -X POST http://127.0.0.1:8888/cluster-configs -d @config.json`
    echo $output
done
