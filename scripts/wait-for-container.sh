#!/usr/bin/env bash

set -e

_CONTAINER_NAME=$1
_CONTAINER_PORT=$2

docker inspect --format "{{ .NetworkSettings.IPAddress }}:${_CONTAINER_PORT}" ${_CONTAINER_NAME} | xargs wget --retry-connrefused --tries=5 -q --wait=10 --spider
