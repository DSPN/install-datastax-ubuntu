#!/usr/bin/env bash

#
# Generate cassandra-env.sh.new
#
MAX_HEAP_SIZE="14G"
HEAP_NEWSIZE="3G"

# Change values and uncomment if needed
cat cassandra-env.sh \
| sed -e "s:^[#]*\(MAX_HEAP_SIZE\=\).*:MAX_HEAP_SIZE\=\"$MAX_HEAP_SIZE\":" \
| sed -e "s:^[#]*\(HEAP_NEWSIZE\=\).*:HEAP_NEWSIZE\=\"$HEAP_NEWSIZE\":" \
> cassandra-env.sh.new
(set -x; chown cassandra:cassandra cassandra-env.sh.new)
(set -x; diff cassandra-env.sh cassandra-env.sh.new)
(set -x; mv -f cassandra-env.sh.new cassandra-env.sh)
