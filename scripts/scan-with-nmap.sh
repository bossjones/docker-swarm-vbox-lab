#!/usr/bin/env bash

echo -e "----------[swarm-manager]---------------\n"
nmap -v $(docker-machine ip swarm-manager)
echo -e "----------[node-01]---------------------\n"
nmap -v $(docker-machine ip node-01)
echo -e "----------[node-02]---------------------\n"
nmap -v $(docker-machine ip node-02)
echo -e "----------[node-03]---------------------\n"
nmap -v $(docker-machine ip node-03)
