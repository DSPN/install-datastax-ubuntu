#!/usr/bin/env bash

# I'm not convinced this is actually working, but going to move on and come back to it.
# ulimit -n is giving 1024

date=$(date +%F)
backup="/etc/security/limits.conf.$date"
cp /etc/security/limits.conf $backup

cat <</EOF > /etc/security/limits.conf
root             -      memlock          unlimited
root             -      nofile           100000
root             -      nproc            32768
root             -      as               unlimited

cassandra        -      memlock          unlimited
cassandra        -      nofile           100000
cassandra        -      nproc            32768
cassandra        -      as               unlimited
/EOF
