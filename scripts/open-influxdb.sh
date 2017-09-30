#!/usr/bin/env bash

# influxdb admin
open http://`docker-machine ip swarm-manager`:8083
# influxdb http
open http://`docker-machine ip swarm-manager`:8086
