#!/usr/bin/env bash

set -e

# docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'

_INFLUX_IP=$(docker-machine ip swarm-manager)

CreateCadvisorDatabase() {
  curl -i -XPOST http://${_INFLUX_IP}:8086/query --data-urlencode "q=CREATE DATABASE mydb"
}

until CreateCadvisorDatabase; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'

wait
