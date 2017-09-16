#!/usr/bin/env bash

set -e

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# http://www.tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap6sec70.html
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.ip_local_port_range=8192 61000
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
# http://tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap6sec75.html
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_fin_timeout=30
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_tw_recycle=1
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_tw_reuse=1
# https://russ.garrett.co.uk/2009/01/01/linux-kernel-tuning/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.core.netdev_max_backlog=8192
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_window_scaling=1
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_keepalive_time=3600
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_timestamps=0
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_max_syn_backlog=8192
# Enable TCP SYN Cookie Protection
# http://www.tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap5sec56.html
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_syncookies=1
# https://tweaked.io/guide/kernel/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.core.somaxconn=1024
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.core.optmem_max=20480
# https://russ.garrett.co.uk/2009/01/01/linux-kernel-tuning/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w vm.min_free_kbytes=65536

# https://wwwx.cs.unc.edu/~sparkst/howto/network_tuning.php
# This sets the default OS receive buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.core.rmem_default = 262144
# This sets the max OS receive buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.core.rmem_max = 8388608
# This sets the default OS send buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.core.wmem_default = 262144
# This sets the max OS send buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.core.wmem_max = 8388608
# The tcp_mem variable defines how the TCP stack should behave when it comes to memory usage. ... The first value specified in the tcp_mem variable tells the kernel the low threshold. Below this point, the TCP stack do not bother at all about putting any pressure on the memory usage by different TCP sockets. ... The second value tells the kernel at which point to start pressuring memory usage down. ... The final value tells the kernel how many memory pages it may use maximally. If this value is reached, TCP streams and packets start getting dropped until we reach a lower memory usage again. This value includes all TCP sockets currently in use.
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_mem='131072 2097152 16777216'
# The first value tells the kernel the minimum receive buffer for each TCP connection, and this buffer is always allocated to a TCP socket, even under high pressure on the system. ... The second value specified tells the kernel the default receive buffer allocated for each TCP socket. This value overrides the /proc/sys/net/core/rmem_default value used by other protocols. ... The third and last value specified in this variable specifies the maximum receive buffer that can be allocated for a TCP socket.
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_rmem='8192 1048576 8388608'
# This variable takes 3 different values which holds information on how much TCP sendbuffer memory space each TCP socket has to use. Every TCP socket has this much buffer space to use before the buffer is filled up. Each of the three values are used under different conditions. ... The first value in this variable tells the minimum TCP send buffer space available for a single TCP socket. ... The second value in the variable tells us the default buffer space allowed for a single TCP socket to use. ... The third value tells the kernel the maximum TCP send buffer space.
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.tcp_wmem='8192 655360 8388608'

# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Performance_Tuning_Guide/s-memory-tunables.html
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w vm.swappiness=5

${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.netfilter.ip_conntrack_max=1024000
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.nf_conntrack_max=1024000

${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.neigh.default.gc_thresh1=512
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.neigh.default.gc_thresh2=2048
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv4.neigh.default.gc_thresh3=4096

# http://blog.sorah.jp/2012/01/24/inotify-limitation
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w fs.inotify.max_user_watches=65535

##################
## Disable IPv6 ##
##################

# ${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
# ${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
# ${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1


# --------------------------------------------------------------------------------------


# http://www.tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap6sec70.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.ip_local_port_range=8192 61000
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
# http://tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap6sec75.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_fin_timeout=30
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_tw_recycle=1
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_tw_reuse=1
# https://russ.garrett.co.uk/2009/01/01/linux-kernel-tuning/
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.core.netdev_max_backlog=8192
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_window_scaling=1
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_keepalive_time=3600
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_timestamps=0
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_max_syn_backlog=8192
# Enable TCP SYN Cookie Protection
# http://www.tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap5sec56.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_syncookies=1
# https://tweaked.io/guide/kernel/
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.core.somaxconn=1024
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.core.optmem_max=20480
# https://russ.garrett.co.uk/2009/01/01/linux-kernel-tuning/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w vm.min_free_kbytes=65536

# https://wwwx.cs.unc.edu/~sparkst/howto/network_tuning.php
# This sets the default OS receive buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.core.rmem_default = 262144
# This sets the max OS receive buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.core.rmem_max = 8388608
# This sets the default OS send buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.core.wmem_default = 262144
# This sets the max OS send buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.core.wmem_max = 8388608
# The tcp_mem variable defines how the TCP stack should behave when it comes to memory usage. ... The first value specified in the tcp_mem variable tells the kernel the low threshold. Below this point, the TCP stack do not bother at all about putting any pressure on the memory usage by different TCP sockets. ... The second value tells the kernel at which point to start pressuring memory usage down. ... The final value tells the kernel how many memory pages it may use maximally. If this value is reached, TCP streams and packets start getting dropped until we reach a lower memory usage again. This value includes all TCP sockets currently in use.
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_mem='131072 2097152 16777216'
# The first value tells the kernel the minimum receive buffer for each TCP connection, and this buffer is always allocated to a TCP socket, even under high pressure on the system. ... The second value specified tells the kernel the default receive buffer allocated for each TCP socket. This value overrides the /proc/sys/net/core/rmem_default value used by other protocols. ... The third and last value specified in this variable specifies the maximum receive buffer that can be allocated for a TCP socket.
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_rmem='8192 1048576 8388608'
# This variable takes 3 different values which holds information on how much TCP sendbuffer memory space each TCP socket has to use. Every TCP socket has this much buffer space to use before the buffer is filled up. Each of the three values are used under different conditions. ... The first value in this variable tells the minimum TCP send buffer space available for a single TCP socket. ... The second value in the variable tells us the default buffer space allowed for a single TCP socket to use. ... The third value tells the kernel the maximum TCP send buffer space.
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.tcp_wmem='8192 655360 8388608'

# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Performance_Tuning_Guide/s-memory-tunables.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w vm.swappiness=5

${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.netfilter.ip_conntrack_max=1024000
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.nf_conntrack_max=1024000

${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.neigh.default.gc_thresh1=512
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.neigh.default.gc_thresh2=2048
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv4.neigh.default.gc_thresh3=4096

# http://blog.sorah.jp/2012/01/24/inotify-limitation
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w fs.inotify.max_user_watches=65535

##################
## Disable IPv6 ##
##################

# ${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
# ${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
# ${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1


# ---------------------------------------------------------------------------------


# http://www.tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap6sec70.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.ip_local_port_range=8192 61000
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
# http://tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap6sec75.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_fin_timeout=30
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_tw_recycle=1
# http://www.linuxbrigade.com/reduce-time_wait-socket-connections/
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_tw_reuse=1
# https://russ.garrett.co.uk/2009/01/01/linux-kernel-tuning/
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.core.netdev_max_backlog=8192
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_window_scaling=1
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_keepalive_time=3600
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_timestamps=0
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_max_syn_backlog=8192
# Enable TCP SYN Cookie Protection
# http://www.tldp.org/LDP/solrhe/Securing-Optimizing-Linux-RH-Edition-v1.3/chap5sec56.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_syncookies=1
# https://tweaked.io/guide/kernel/
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.core.somaxconn=1024
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.core.optmem_max=20480
# https://russ.garrett.co.uk/2009/01/01/linux-kernel-tuning/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w vm.min_free_kbytes=65536

# https://wwwx.cs.unc.edu/~sparkst/howto/network_tuning.php
# This sets the default OS receive buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.core.rmem_default = 262144
# This sets the max OS receive buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.core.rmem_max = 8388608
# This sets the default OS send buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.core.wmem_default = 262144
# This sets the max OS send buffer size for all types of connections.
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.core.wmem_max = 8388608
# The tcp_mem variable defines how the TCP stack should behave when it comes to memory usage. ... The first value specified in the tcp_mem variable tells the kernel the low threshold. Below this point, the TCP stack do not bother at all about putting any pressure on the memory usage by different TCP sockets. ... The second value tells the kernel at which point to start pressuring memory usage down. ... The final value tells the kernel how many memory pages it may use maximally. If this value is reached, TCP streams and packets start getting dropped until we reach a lower memory usage again. This value includes all TCP sockets currently in use.
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_mem='131072 2097152 16777216'
# The first value tells the kernel the minimum receive buffer for each TCP connection, and this buffer is always allocated to a TCP socket, even under high pressure on the system. ... The second value specified tells the kernel the default receive buffer allocated for each TCP socket. This value overrides the /proc/sys/net/core/rmem_default value used by other protocols. ... The third and last value specified in this variable specifies the maximum receive buffer that can be allocated for a TCP socket.
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_rmem='8192 1048576 8388608'
# This variable takes 3 different values which holds information on how much TCP sendbuffer memory space each TCP socket has to use. Every TCP socket has this much buffer space to use before the buffer is filled up. Each of the three values are used under different conditions. ... The first value in this variable tells the minimum TCP send buffer space available for a single TCP socket. ... The second value in the variable tells us the default buffer space allowed for a single TCP socket to use. ... The third value tells the kernel the maximum TCP send buffer space.
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.tcp_wmem='8192 655360 8388608'

# https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Performance_Tuning_Guide/s-memory-tunables.html
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w vm.swappiness=5

${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.netfilter.ip_conntrack_max=1024000
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.nf_conntrack_max=1024000

${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.neigh.default.gc_thresh1=512
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.neigh.default.gc_thresh2=2048
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv4.neigh.default.gc_thresh3=4096

# http://blog.sorah.jp/2012/01/24/inotify-limitation
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w fs.inotify.max_user_watches=65535

##################
## Disable IPv6 ##
##################

# ${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
# ${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
# ${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1

# --------------------

# Needed for elasticsearch
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager sudo sysctl -w vm.max_map_count=262144
${_DIR}/../bin/docker-machine-x86_64 ssh node-01 sudo sysctl -w vm.max_map_count=262144
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 sudo sysctl -w vm.max_map_count=262144
