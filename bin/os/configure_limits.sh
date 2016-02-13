#!/usr/bin/env bash

#
# configure limits
#

limitd_dir=/etc/security/limits.d

cd "$security_dir"
cat limits.conf \
| grep -v 'root.*memlock.*' \
| grep -v 'root.*nofile.*' \
| grep -v 'root.*nproc.*' \
| grep -v 'root.*as.*' \
| grep -v 'cassandra.*memlock.*' \
| grep -v 'cassandra.*nofile.*' \
| grep -v 'cassandra.*nproc.*' \
| grep -v 'cassandra.*as.*' \
> limits.conf.new
cat <</EOF >> limits.conf.new
root             -      memlock          unlimited
root             -      nofile           100000
root             -      nproc            32768
root             -      as               unlimited

cassandra        -      memlock          unlimited
cassandra        -      nofile           100000
cassandra        -      nproc            32768
cassandra        -      as               unlimited
/EOF
(set -x; chown cassandra:cassandra limits.conf.new)
(set -x; diff limits.conf limits.conf.new)
(set -x; mv -f limits.conf.new limits.conf)
