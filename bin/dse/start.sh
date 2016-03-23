#!/usr/bin/env bash

echo "Starting DataStax Enterprise"
sudo service dse start

echo "Starting the DataStax Agent"
sudo service datastax-agent start
