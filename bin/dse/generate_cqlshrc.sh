#!/usr/bin/env bash

mkdir $HOME/.cassandra
set -x; chown cassandra:cassandra $HOME/.cassandra
chmod 777 $HOME/.cassandra
cat <</EOF >$HOME/.cassandra/cqlshrc
[connection]
client_timeout = 600
hostname = $node_private_ip
port = 9042
/EOF
(set -x; chown cassandra:cassandra $HOME/.cassandra/cqlshrc)
(set -x; chmod 755 $HOME/.cassandra/cqlshrc)
