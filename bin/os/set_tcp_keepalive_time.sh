#!/usr/bin/env bash

# Azure public IPs have some odd timeout behaviour.
# A good summary is available here: https://docs.mongodb.org/ecosystem/platforms/windows-azure/

echo "net.ipv4.tcp_keepalive_time = 120" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf
