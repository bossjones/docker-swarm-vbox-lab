.PHONY: test clean

# https://stackoverflow.com/questions/7897549/make-ignores-my-python-bash-alias

DOCKER_VERSION := 17.05.0-ce
DOCKER_MACHINE_VERSION := v0.12.2
DOCKER_COMPOSE_VERSION := 1.16.1

MKDIR = mkdir
DM = ./bin/docker-machine-x86_64
DC = ./bin/docker-compose-x86_64

# docker version manager ( this doesnt work I think )
bootstrap-dvm:
	@bash ./scripts/bootstrap-dvm.sh

create-dm-local:
	./bin/docker-machine-x86_64 create -d virtualbox local

echo-discotoken:
	@echo "${discotoken}"

create-dm-swarm-manager:
	./bin/docker-machine-x86_64 create \
	-d virtualbox \
	--swarm \
	--swarm-master \
	--swarm-discovery token://${discotoken} \
	swarm-manager

create-dm-node-01:
	./bin/docker-machine-x86_64 create \
	-d virtualbox \
	--swarm \
	--swarm-discovery token://${discotoken} \
	node-01

dm-ls:
	$(DM) ls

# source: https://unix.stackexchange.com/questions/269912/send-command-to-the-shell-via-makefile
env-dm-local:
	echo $$(./bin/docker-machine-x86_64 env local) > ./dm-local-env
	@echo "Run this command to configure your shell: # source ./dm-local-env"

dvm-use:
	dvm use $(DOCKER_VERSION)

install-docker-via-dvm:
	dvm install 17.05.0-ce
	dvm use 17.05.0-ce

install-dm-completions:
	$(MKDIR) -p .bash_completion.d
	@bash ./scripts/install-dm-completions.sh

./bin/docker-compose-x86_64:
	curl -L https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` > ./bin/docker-compose-x86_64 && \
	chmod + ./bin/docker-compose-x86_64
	./bin/docker-compose-x86_64 version

./bin/docker-machine-x86_64:
	curl -L https://github.com/docker/machine/releases/download/$(DOCKER_MACHINE_VERSION)/docker-machine-`uname -s`-`uname -m` > ./bin/docker-machine-x86_64 && \
	chmod +x ./bin/docker-machine-x86_64
	./bin/docker-machine-x86_64 version

bootstrap-docker-toolbox: ./bin/docker-compose-x86_64 ./bin/docker-machine-x86_64

test:
	@docker --version

clean:
	$(RM) ./bin/docker-compose-x86_64
	$(RM) ./bin/docker-machine-x86_64
