#!/usr/bin/env bash

set -e

scripts=( docker-machine-prompt.bash docker-machine-wrapper.bash docker-machine.bash ); for i in "${scripts[@]}"; do curl -L https://raw.githubusercontent.com/docker/machine/$(DOCKER_MACHINE_VERSION)/contrib/completion/bash/${i} > .bash_completion.d/${i}; done
