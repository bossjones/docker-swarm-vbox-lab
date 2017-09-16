#!/usr/bin/env bash

set -e

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

${_DIR}/../bin/docker-machine-x86_64 env local
echo
eval "$(${_DIR}/../bin/docker-machine-x86_64 env local)"
echo
env | grep -i docker
