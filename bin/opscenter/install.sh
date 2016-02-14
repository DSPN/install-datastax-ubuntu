#!/usr/bin/env bash

echo "Installing OpsCenter"
echo "deb http://debian.datastax.com/community stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.community.list
curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get update
apt-get -y install opscenter=5.2.4

# The install creates a cassandra user, so now we can do this:
chown cassandra /mnt
chgrp cassandra /mnt
