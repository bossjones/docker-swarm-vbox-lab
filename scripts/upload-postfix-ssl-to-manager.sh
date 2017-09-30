#!/usr/bin/env bash

set -e

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Get all the certs on the swarm-manager
${_DIR}/../bin/docker-machine-x86_64 scp swarm-manager \
    ${_DIR}/../contrib/keys/postfix.key docker@swarm-manager:.
${_DIR}/../bin/docker-machine-x86_64 scp swarm-manager \
    ${_DIR}/../contrib/keys/postfix.crt docker@swarm-manager:.
${_DIR}/../bin/docker-machine-x86_64 scp swarm-manager \
    ${_DIR}/../contrib/keys/postfix.ca.crt docker@swarm-manager:.

# chown it to root
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager \
    sudo chown root:root -R postfix.key postfix.crt postfix.ca.crt

# copy it to the correct place now
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager \
    sudo cp -r postfix.* /etc/ssl/private/
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager \
    sudo cp -r postfix.* /usr/local/share/ca-certificates/

# Run update-ca-certificates command
${_DIR}/../bin/docker-machine-x86_64 ssh swarm-manager \
    sudo update-ca-certificates

