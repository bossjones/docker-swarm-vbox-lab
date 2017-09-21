#!/usr/bin/env bash

set -e

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# make sure dvm is working, otherwise, stop here
[ -f /usr/local/opt/dvm/dvm.sh ] && . /usr/local/opt/dvm/dvm.sh
[[ -r $DVM_DIR/bash_completion ]] && . $DVM_DIR/bash_completion

dvm ls
dmv use 17.05.0-ce
docker ps

# TODO: implement a check for this
# source: http://www.georgevreilly.com/blog/2015/12/23/ParseMinVerBash.html

# connect to docker-swarm manager
echo $(${_DIR}/../bin/docker-machine-x86_64 env swarm-manager) > ./dm-swarm-manager-env
source ./dm-swarm-manager-env

# NOTE: example contents of above ^
# export DOCKER_TLS_VERIFY="1"
# export DOCKER_HOST="tcp://192.168.99.101:2376"
# export DOCKER_CERT_PATH="/Users/malcolm/.docker/machine/machines/swarm-manager"
# export DOCKER_MACHINE_NAME="swarm-manager"

# make sure it works
docker ps

# Remove all swarm workers
docker node rm --force node-01
docker node rm --force node-02
docker node rm --force node-03

# Get swarm-manager ip address for its docker-machine
MANAGER_IP=$(${_DIR}/../bin/docker-machine-x86_64 ip swarm-manager)
echo ${MANAGER_IP}

# Get token that will be used in joining agents to new swarm master
WORKER_TOKEN=$(${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager docker swarm join-token --quiet worker)
echo ${WORKER_TOKEN}

${_DIR}/../bin/docker-machine-x86_64 ssh node-01 docker swarm leave
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 docker swarm leave
${_DIR}/../bin/docker-machine-x86_64 ssh node-03 docker swarm leave

${_DIR}/../bin/docker-machine-x86_64 ssh node-01 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
${_DIR}/../bin/docker-machine-x86_64 ssh node-02 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
${_DIR}/../bin/docker-machine-x86_64 ssh node-03 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377

echo $(${_DIR}/../bin/docker-machine-x86_64 env swarm-manager) > ./dm-swam-manager-env
source ./dm-swam-manager-env

# prove it worked
docker node ls

# cleanup
rm ./dm-swam-manager-env
