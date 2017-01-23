#!/usr/bin/env bash

dsefs_data_path=$1
echo dsefs_data_path \'$dsefs_data_path\' in configure_dsefs_data.sh

chown cassandra:cassandra $dsefs_data_path

