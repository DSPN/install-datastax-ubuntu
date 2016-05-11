#!/usr/bin/env bash

cloud_type=$1

echo "Installing DataStax Enterprise"

if [[ $cloud_type == "azure" ]]; then
  echo "deb https://datastax%40microsoft.com:3A7vadPHbNT@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
elif [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  echo "deb https://datastax%40google.com:8GdeeVT2s7zi@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
else
  echo $cloud_type is not supported 1>&2
  exit 99
fi

curl -L https://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get -y update

dse_version=4.8.5-1
apt-get -y install dse-full=$dse_version dse=$dse_version dse-hive=$dse_version dse-pig=$dse_version dse-demos=$dse_version dse-libsolr=$dse_version dse-libtomcat=$dse_version dse-libsqoop=$dse_version dse-liblog4j=$dse_version dse-libmahout=$dse_version dse-libhadoop-native=$dse_version dse-libcassandra=$dse_version dse-libhive=$dse_version dse-libpig=$dse_version dse-libhadoop=$dse_version dse-libspark=$dse_version

# The install of dse creates a cassandra user, so now we can do this:
chown cassandra /mnt
chgrp cassandra /mnt
