#!/usr/bin/env bash

echo "Installing the Oracle JDK"

# Install add-apt-repository
apt-get -y install software-properties-common

add-apt-repository -y ppa:webupd8team/java
apt-get -y update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get -y install oracle-java8-installer

# We're seeing Java installs fail intermittently.  Retrying indefinitely seems problematic.  I'm not sure
# what the correct solution is.  For now, we're just going to run the install a second time.  This will do
# nothing if the first install was successful and I suspect will eliminate the majority of our failures.
apt-get -y install oracle-java8-installer
