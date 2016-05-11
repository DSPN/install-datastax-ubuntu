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

# We're seeing a concurrency bug.  Advice from engineering is to restart OpsCenter.
# This doesn't entirely fix the agent connectivity problem, but it seems to resolve some cases of it.
sleep 60
sudo service opscenterd restart
