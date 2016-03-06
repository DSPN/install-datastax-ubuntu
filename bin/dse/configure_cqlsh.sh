#!/usr/bin/env bash

###### This doesn't really work.  It makes the assumption that the setup user is the login user.
# It's not in most cases.
# Need to set this globally somehow

node_broadcast_ip=$1

# By default cqlsh connects to 127.0.0.1.
# In a mutlinode cluster this causes issues with the driver connecting to other nodes
# So, we need to connect to the broadbast IP for that node

mkdir $HOME/.cassandra

chown cassandra:cassandra $HOME/.cassandra
chmod 777 $HOME/.cassandra

cat <</EOF >$HOME/.cassandra/cqlshrc
[connection]
hostname = $node_broadcast_ip
/EOF

chown cassandra:cassandra $HOME/.cassandra/cqlshrc
chmod 755 $HOME/.cassandra/cqlshrc
