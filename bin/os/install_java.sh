#!/usr/bin/env bash

echo "Installing the Oracle JDK"

# Install add-apt-repository, removeable?
apt-get -y install software-properties-common

wget --no-cookies --no-check-certificate \
--header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz"

tar -xvf jdk-8u151-linux-x64.tar.gz -C /opt/

update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_151/bin/java 100
update-alternatives --set java /opt/jdk1.8.0_151/bin/java
update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_151/bin/javac 100
update-alternatives --set javac /opt/jdk1.8.0_151/bin/javac
update-alternatives --install /usr/bin/keytool keytool /opt/jdk1.8.0_151/bin/keytool 100
update-alternatives --set keytool /opt/jdk1.8.0_151/bin/keytool
