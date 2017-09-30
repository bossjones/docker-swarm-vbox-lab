#!/usr/bin/env bash

open http://`docker-machine ip swarm-manager`:8080
open http://`docker-machine ip node-01`:8080
open http://`docker-machine ip node-02`:8080
open http://`docker-machine ip node-03`:8080
