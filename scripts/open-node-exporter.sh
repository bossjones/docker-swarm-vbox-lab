#!/usr/bin/env bash

open http://`docker-machine ip swarm-manager`:9100
open http://`docker-machine ip node-01`:9100
open http://`docker-machine ip node-02`:9100
open http://`docker-machine ip node-03`:9100
