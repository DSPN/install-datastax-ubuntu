#!/usr/bin/env bash

json=`curl http://127.0.0.1:8888/Test_Cluster/nodes/all/dc`
dcs=`echo $json | grep -Po '(?<=: ")[^"]*'`
dc=`echo $dcs | cut -d' ' -f1`

curl -X PUT http://127.0.0.1:8888/Test_Cluster/keyspaces/OpsCenter -d "{
    \"strategy_class\": \"org.apache.cassandra.locator.NetworkTopologyStrategy\",
    \"strategy_options\": {\"$dc\": \"2\"},
    \"durable_writes\": true
  }"

