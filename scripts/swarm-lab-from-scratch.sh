#!/usr/bin/env bash

set -e

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make sure dvm is working, otherwise, stop here
[ -f /usr/local/opt/dvm/dvm.sh ] && . /usr/local/opt/dvm/dvm.sh
[[ -r $DVM_DIR/bash_completion ]] && . $DVM_DIR/bash_completion

dvm ls
dmv use 17.05.0-ce
docker ps


${_DIR}/../bin/docker-machine-x86_64 create -d virtualbox local
echo $(./docker-machine-Linux-x86_64 env local) > ./dm-local-env
source ./dm-local-env

# make sure it works
docker ps

# Setup all of the virtualbox machines
${_DIR}/../bin/docker-machine-x86_64 create -d virtualbox swarm-manager
${_DIR}/../bin/docker-machine-x86_64 create -d virtualbox node-01
${_DIR}/../bin/docker-machine-x86_64 create -d virtualbox node-02
${_DIR}/../bin/docker-machine-x86_64 create -d virtualbox node-03

# Get swarm-manager ip address for its docker-machine
MANAGER_IP=$(${_DIR}/../bin/docker-machine-x86_64 ip swarm-manager)
echo ${MANAGER_IP}

# Turn this into the swarm master
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager docker swarm init --advertise-addr ${MANAGER_IP}

# Get token that will be used in joining agents to new swarm master
WORKER_TOKEN=$(${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager docker swarm join-token --quiet worker)
echo ${WORKER_TOKEN}

${_DIR}/../bin/docker-machine-x86_64 ssh node-01 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
${_DIR}/../bin/docker-machine-x86_64 ssh node-03 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377

echo $(${_DIR}/../bin/docker-machine-x86_64 env swarm-manager) > ./dm-swam-manager-env
source ./dm-swam-manager-env

# prove it worked
docker node ls
