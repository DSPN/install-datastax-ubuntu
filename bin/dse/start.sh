#!/usr/bin/env bash

echo "Starting DataStax Enterprise"
sudo service dse start

# We don't need to start the DataStax agent.  The "manage existing cluster" call will start it for us.
