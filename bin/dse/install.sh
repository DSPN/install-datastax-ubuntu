#!/usr/bin/env bash

echo "Installing DataStax Enterprise"
echo "deb https://datastax%40microsoft.com:3A7vadPHbNT@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get -y update
apt-get -y install dse-full=4.8.4-1

# The install creates a cassandra user, so now we can do this:
chown cassandra /mnt
chgrp cassandra /mnt
