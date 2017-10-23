#!/usr/bin/env bash

usage="---------------------------------------------------
Usage:
install_java.sh [-h] [-m]

Options:

 -h   : display this message and exit
 -m   : manual tar install (default is package)

---------------------------------------------------"


while getopts 'hm' opt; do
  case $opt in
    h) echo -e "$usage"
       exit
    ;;
    m) manual="true"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
        exit 1
    ;;
  esac
done

echo "Installing the Oracle JDK"

if [ -z "$manual" ]; then
  echo "performing package install"
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
else
  echo "-m flag passed, performing manual tar install"
  wget --no-cookies --no-check-certificate \
  --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
  "http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz"

  tar -xvf jdk-8u151-linux-x64.tar.gz -C /opt/
  # minimal update-alternatives calls
  update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_151/bin/java 100
  update-alternatives --set java /opt/jdk1.8.0_151/bin/java
  update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_151/bin/javac 100
  update-alternatives --set javac /opt/jdk1.8.0_151/bin/javac
  update-alternatives --install /usr/bin/keytool keytool /opt/jdk1.8.0_151/bin/keytool 100
  update-alternatives --set keytool /opt/jdk1.8.0_151/bin/keytool
  # remaining install
  update-alternatives --install /usr/bin/ControlPanel ControlPanel /usr/lib/jvm/java-8-oracle/jre/bin/ControlPanel 100
  update-alternatives --install /usr/bin/javaws javaws /usr/lib/jvm/java-8-oracle/jre/bin/javaws 100
  update-alternatives --install /usr/bin/jcontrol jcontrol /usr/lib/jvm/java-8-oracle/jre/bin/jcontrol 100
  update-alternatives --install /usr/bin/jjs jjs /usr/lib/jvm/java-8-oracle/jre/bin/jjs 100
  update-alternatives --install /usr/bin/orbd orbd /usr/lib/jvm/java-8-oracle/jre/bin/orbd 100
  update-alternatives --install /usr/bin/pack200 pack200 /usr/lib/jvm/java-8-oracle/jre/bin/pack200 100
  update-alternatives --install /usr/bin/policytool policytool /usr/lib/jvm/java-8-oracle/jre/bin/policytool 100
  update-alternatives --install /usr/bin/rmid rmid /usr/lib/jvm/java-8-oracle/jre/bin/rmid 100
  update-alternatives --install /usr/bin/rmiregistry rmiregistry /usr/lib/jvm/java-8-oracle/jre/bin/rmiregistry 100
  update-alternatives --install /usr/bin/servertool servertool /usr/lib/jvm/java-8-oracle/jre/bin/servertool 100
  update-alternatives --install /usr/bin/tnameserv tnameserv /usr/lib/jvm/java-8-oracle/jre/bin/tnameserv 100
  update-alternatives --install /usr/bin/unpack200 unpack200 /usr/lib/jvm/java-8-oracle/jre/bin/unpack200 100
  update-alternatives --install /usr/bin/jexec jexec /usr/lib/jvm/java-8-oracle/jre/lib/jexec 100
  update-alternatives --install /usr/bin/appletviewer appletviewer /usr/lib/jvm/java-8-oracle/bin/appletviewer 100
  update-alternatives --install /usr/bin/extcheck extcheck /usr/lib/jvm/java-8-oracle/bin/extcheck 100
  update-alternatives --install /usr/bin/idlj idlj /usr/lib/jvm/java-8-oracle/bin/idlj 100
  update-alternatives --install /usr/bin/jar jar /usr/lib/jvm/java-8-oracle/bin/jar 100
  update-alternatives --install /usr/bin/jarsigner jarsigner /usr/lib/jvm/java-8-oracle/bin/jarsigner 100
  update-alternatives --install /usr/bin/javadoc javadoc /usr/lib/jvm/java-8-oracle/bin/javadoc 100
  update-alternatives --install /usr/bin/javafxpackager javafxpackager /usr/lib/jvm/java-8-oracle/bin/javafxpackager 100
  update-alternatives --install /usr/bin/javah javah /usr/lib/jvm/java-8-oracle/bin/javah 100
  update-alternatives --install /usr/bin/javap javap /usr/lib/jvm/java-8-oracle/bin/javap 100
  update-alternatives --install /usr/bin/javapackager javapackager /usr/lib/jvm/java-8-oracle/bin/javapackager 100
  update-alternatives --install /usr/bin/jcmd jcmd /usr/lib/jvm/java-8-oracle/bin/jcmd 100
  update-alternatives --install /usr/bin/jconsole jconsole /usr/lib/jvm/java-8-oracle/bin/jconsole 100
  update-alternatives --install /usr/bin/jdb jdb /usr/lib/jvm/java-8-oracle/bin/jdb 100
  update-alternatives --install /usr/bin/jdeps jdeps /usr/lib/jvm/java-8-oracle/bin/jdeps 100
  update-alternatives --install /usr/bin/jhat jhat /usr/lib/jvm/java-8-oracle/bin/jhat 100
  update-alternatives --install /usr/bin/jinfo jinfo /usr/lib/jvm/java-8-oracle/bin/jinfo 100
  update-alternatives --install /usr/bin/jmap jmap /usr/lib/jvm/java-8-oracle/bin/jmap 100
  update-alternatives --install /usr/bin/jmc jmc /usr/lib/jvm/java-8-oracle/bin/jmc 100
  update-alternatives --install /usr/bin/jps jps /usr/lib/jvm/java-8-oracle/bin/jps 100
  update-alternatives --install /usr/bin/jrunscript jrunscript /usr/lib/jvm/java-8-oracle/bin/jrunscript 100
  update-alternatives --install /usr/bin/jsadebugd jsadebugd /usr/lib/jvm/java-8-oracle/bin/jsadebugd 100
  update-alternatives --install /usr/bin/jstack jstack /usr/lib/jvm/java-8-oracle/bin/jstack 100
  update-alternatives --install /usr/bin/jstat jstat /usr/lib/jvm/java-8-oracle/bin/jstat 100
  update-alternatives --install /usr/bin/jstatd jstatd /usr/lib/jvm/java-8-oracle/bin/jstatd 100
  update-alternatives --install /usr/bin/jvisualvm jvisualvm /usr/lib/jvm/java-8-oracle/bin/jvisualvm 100
  update-alternatives --install /usr/bin/native2ascii native2ascii /usr/lib/jvm/java-8-oracle/bin/native2ascii 100
  update-alternatives --install /usr/bin/rmic rmic /usr/lib/jvm/java-8-oracle/bin/rmic 100
  update-alternatives --install /usr/bin/schemagen schemagen /usr/lib/jvm/java-8-oracle/bin/schemagen 100
  update-alternatives --install /usr/bin/serialver serialver /usr/lib/jvm/java-8-oracle/bin/serialver 100
  update-alternatives --install /usr/bin/wsgen wsgen /usr/lib/jvm/java-8-oracle/bin/wsgen 100
  update-alternatives --install /usr/bin/wsimport wsimport /usr/lib/jvm/java-8-oracle/bin/wsimport 100
  update-alternatives --install /usr/bin/xjc xjc /usr/lib/jvm/java-8-oracle/bin/xjc 100
  update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /usr/lib/jvm/java-8-oracle/jre/lib/amd64/libnpjp2.so 100
  # remaining set
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/ControlPanel
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/javaws
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/jcontrol
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/jjs
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/orbd
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/pack200
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/policytool
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/rmid
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/rmiregistry
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/servertool
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/tnameserv
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/bin/unpack200
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/lib/jexec
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/appletviewer
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/extcheck
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/idlj
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jar
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jarsigner
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/javadoc
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/javafxpackager
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/javah
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/javap
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/javapackager
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jcmd
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jconsole
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jdb
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jdeps
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jhat
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jinfo
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jmap
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jmc
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jps
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jrunscript
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jsadebugd
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jstack
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jstat
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jstatd
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/jvisualvm
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/native2ascii
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/rmic
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/schemagen
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/serialver
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/wsgen
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/wsimport
  update-alternatives --set /usr/lib/jvm/java-8-oracle/bin/xjc
  update-alternatives --set /usr/lib/jvm/java-8-oracle/jre/lib/amd64/libnpjp2.so
fi
