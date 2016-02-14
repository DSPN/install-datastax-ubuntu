#!/usr/bin/env bash

# I'm not convinced this is actually working, but going to move on and come back to it.
# ulimit -n is giving 1024

file=/etc/security/limits.conf

date=$(date +%F)
backup="$file.$date"
cp $file $backup

cat <</EOF > $file
root             -      memlock          unlimited
root             -      nofile           100000
root             -      nproc            32768
root             -      as               unlimited

cassandra        -      memlock          unlimited
cassandra        -      nofile           100000
cassandra        -      nproc            32768
cassandra        -      as               unlimited
/EOF
