#!/usr/bin/env bash

echo "Installing the Oracle JDK"

JDK_BUILD_VERSION=152
JDK_VERSION=8u$JDK_BUILD_VERSION
JDK_FILE=jdk-$JDK_VERSION-linux-x64.tar.gz
# Install add-apt-repository
sudo mkdir -p /usr/lib/jvm
# This isn't a reliable source, but it's good for now until we can use DSE >5.1.7
# Waiting for a fix for DSE-15622 then we can use the cleaner java install method
wget http://ftp2.us.debian.org/pub/funtoo/distfiles/oracle-java/$JDK_FILE
sudo tar zxvf $JDK_FILE -C /usr/lib/jvm
sudo update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_$JDK_BUILD_VERSION/bin/java" 1
sudo update-alternatives --config java
