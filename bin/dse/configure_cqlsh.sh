#!/usr/bin/env bash

node_broadcast_ip=$1

# By default cqlsh connects to 127.0.0.1.
# In a mutlinode cluster this causes issues with the driver connecting to other nodes
# So, we need to connect to the broadbast IP for that node

