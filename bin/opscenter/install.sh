#!/usr/bin/env bash
cloud_type=$1
opscenter_version=6.7.8

if [ -z "$OPSC_VERSION" ]
then
  echo "env \$OPSC_VERSION is not set, using default: $opscenter_version"
else
  echo "env \$OPSC_VERSION is set: $OPSC_VERSION overiding default"
  opscenter_version=$OPSC_VERSION
fi

echo "Installing OpsCenter"

echo "Adding the DataStax repository"
echo "deb https://debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list

echo -e "Checking if apt/dpkg running, start: $(date +%r)"
while ps -A | grep -e apt -e dpkg >/dev/null 2>&1; do sleep 10s; done;
echo -e "No other procs: $(date +%r)"

curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -

apt-get update
apt-get -y install opscenter=$opscenter_version
