#!/usr/bin/env bash

./install_java.sh

./os/configure_limits_conf.sh

./dse/install.sh
./dse/configure.sh
./dse/start.sh
