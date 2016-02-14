#!/usr/bin/env bash

./install_java.sh

./os/configure_limits_conf.sh

cd dse
./install.sh
./configure.sh
./start.sh
cd ..
