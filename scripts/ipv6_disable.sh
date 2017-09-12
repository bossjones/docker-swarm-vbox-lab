#!/usr/bin/env bash

set -x

echo "Disabling IPv6"
sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >>  /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >>  /etc/sysctl.conf
sudo sysctl -p
