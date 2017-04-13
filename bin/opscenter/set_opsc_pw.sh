#!/bin/bash

passwd=$1

echo "Turn on OpsC auth"
sed -ie 's/enabled = False/enabled = True/g' /etc/opscenter/opscenterd.conf

echo "Restart OpsC"
service opscenterd restart

echo "Connect to OpsC after restart..."

for i in `seq 1 10`;
do
  echo "Attempt $i..."
  json=$(curl --retry 10 -s -X POST -d '{"username":"admin","password":"admin"}' 'http://localhost:8888/login')
  RET=$?

  if [ $RET -eq 0 ]
  then
    echo -e "\nSuccess retrieving token."
    break
  fi

  if [ $i -eq 10 ]
  then
    echo "Failure after 10 trys, exiting"
    exit 1
  fi

  sleep 10s
done

echo $json
token=$(curl -s -X POST -d '{"username":"admin","password":"admin"}' 'http://localhost:8888/login' | tr -d '{} ' | awk -F':' {'print $2'} | tr -d '"')
curl -H 'opscenter-session: '$token -H 'Accept: application/json' -d '{"password": "mypasswd", "'$password'": "admin" }' -X PUT http://127.0.0.1:8888/users/admin
