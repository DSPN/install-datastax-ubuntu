#!/usr/bin/env bash

seed_node_public_ip=$1

sudo tee config.json > /dev/null <<EOF
{
  "cassandra": {
    "seed_hosts": "$seed_node_public_ip",
    "max_schema_agreement_wait": 90
  },
  "cassandra_metrics": {},
  "jmx": {
    "port": "7199"
  }
}
EOF

curl -X POST http://127.0.0.1:8888/cluster-configs -d @config.json
