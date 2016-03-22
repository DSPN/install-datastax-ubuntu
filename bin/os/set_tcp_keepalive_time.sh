#!/usr/bin/env bash

# Azure public IPs have some odd keepalive behaviour.
# A good summary is available here: https://docs.mongodb.org/ecosystem/platforms/windows-azure/

# Set it for now
sudo sysctl -w net.ipv4.tcp_keepalive_time=120

# Persistent across reboots
echo "net.ipv4.tcp_keepalive_time = 120" >> /etc/sysctl.conf
echo "" >> /etc/sysctl.conf
