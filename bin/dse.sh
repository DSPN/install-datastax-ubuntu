#!/usr/bin/env bash

./install_java.sh

cd os
./configure.sh

cd dse
./install.sh
./configure.sh
./start.sh
