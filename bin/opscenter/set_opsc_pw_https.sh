#!/bin/bash

password=$1

cp /etc/opscenter/opscenterd.conf /etc/opscenter/opscenterd.conf.bak
echo "Turn on OpsC auth"
sed -ie 's/enabled = False/enabled = True/g' /etc/opscenter/opscenterd.conf

echo "Turn on SSL"
sed -ie 's/#ssl_keyfile/ssl_keyfile/g' /etc/opscenter/opscenterd.conf
sed -ie 's/#ssl_certfile/ssl_certfile/g' /etc/opscenter/opscenterd.conf
sed -ie 's/#ssl_port/ssl_port/g' /etc/opscenter/opscenterd.conf

echo "Restart OpsC"
service opscenterd restart

echo "Connect to OpsC after restart..."

for i in `seq 1 10`;
do
  echo "Attempt $i..."
  json=$(curl --retry 10 -k -s -X POST -d '{"username":"admin","password":"admin"}' 'https://localhost:8443/login')
  RET=$?

  if [ $RET -eq 0 ]
  then
    echo -e "\nSuccess retrieving token."
    break
  fi

  if [ $i -eq 10 ]
  then
    echo "Failure after 10 trys, revert to original config, restart opscenterd, and exit"
    cp /etc/opscenter/opscenterd.conf.bak /etc/opscenter/opscenterd.conf
    service opscenterd restart
    exit 1
  fi

  sleep 10s
done

echo $json
token=$(echo $json | tr -d '{} ' | awk -F':' {'print $2'} | tr -d '"')
curl -k -H 'opscenter-session: '$token -H 'Accept: application/json' -d '{"password": "'$password'", "old_password": "admin" }' -X PUT https://localhost:8443/users/admin
