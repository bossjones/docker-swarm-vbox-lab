DOCKER_VERSION := 17.05.0-ce

# docker version manager ( this doesnt work I think )
bootstrap-dvm:
	@bash ./scripts/bootstrap-dvm.sh

install-docker-via-dvm:
	dvm install 17.05.0-ce
	dvm use 17.05.0-ce

docker-compose-x86_64:
	curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-`uname -s`-`uname -m` > ./bin/docker-compose-x86_64 && \
	chmod + ./bin/docker-compose-x86_64

docker-machine-x86_64:
	curl -L https://github.com/docker/machine/releases/download/v0.12.2/docker-machine-`uname -s`-`uname -m` > ./bin/docker-machine-x86_64 && \
	chmod +x ./bin/docker-machine-x86_64
