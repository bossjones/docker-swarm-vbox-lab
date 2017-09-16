#!/usr/bin/env bash

set -e

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

MANAGER_IP=$(${_DIR}/../bin/docker-machine-x86_64 ip swarm-manager)

# NOTE: directly from https://portainer.readthedocs.io/en/stable/deployment.html#quick-start
docker service create \
    --detach=true \
    --name portainer \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=$(pwd)/data,dst=/data \
    portainer/portainer \
    -H unix:///var/run/docker.sock
    # -H tcp://${MANAGER_IP}:2376
    # -H unix:///var/run/docker.sock

# docker service create \
#   -d \
#   --publish 9008:9000 \
#   --limit-cpu 0.5 \
#   --name portainer-swarm \
#   --constraint=node.role==manager \
#   --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
#   portainer/portainer --swarm


# docker service create \
#   -d \
#   --publish 9009:9000 \
#   --limit-cpu 0.5 \
#   --name portainer \
#   --mode global \
#   --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
#   portainer/portainer
