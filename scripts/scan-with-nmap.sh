#!/usr/bin/env bash

nmap -v -A $(docker-machine ip swarm-manager)
echo -e "----------------------------------------\n"
nmap -v -A $(docker-machine ip node-01)
echo -e "----------------------------------------\n"
nmap -v -A $(docker-machine ip node-02)
echo -e "----------------------------------------\n"
nmap -v -A $(docker-machine ip node-03)
