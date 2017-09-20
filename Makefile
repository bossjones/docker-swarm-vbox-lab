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

bootstrap-swarm-local:
	$(DM) create -d virtualbox local
	# eval $(./bin/docker-machine-x86_64 env local)

# NOTE: Based on
# http://perica.zivkovic.nl/blog/setup-docker-swarm-with-docker-machine-do/
bootstrap-swarm:
	$(DM) create -d virtualbox swarm-manager
	$(DM) create -d virtualbox node-01
	$(DM) create -d virtualbox node-02
	$(DM) create -d virtualbox node-03
	MANAGER_IP=$(./bin/docker-machine-x86_64 ip swarm-manager)
	@echo ${MANAGER_IP}
	# initalize swarm manager
	$(DM) ssh swarm-manager docker swarm init --advertise-addr ${MANAGER_IP}
	WORKER_TOKEN=$(./bin/docker-machine-x86_64 ssh swarm-manager docker swarm join-token --quiet worker)
	@echo ${WORKER_TOKEN}
	$(DM) ssh node-01 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
	$(DM) ssh node-02 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
	$(DM) ssh node-03 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377

swarm-lab-from-scratch:
	@bash ./scripts/swarm-lab-from-scratch.sh

create-monitoring-overlay-network:
	@docker network create monitoring -d overlay

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

# source: https://portainer.readthedocs.io/en/stable/deployment.html
# docker run -d -p 9000:9000 portainer/portainer -H tcp://<SWARM_MANAGER_IP>:2375
broken-install-portainer:
	MANAGER_IP=$(./bin/docker-machine-x86_64 ip swarm-manager)
	@docker pull portainer/portainer; \
	# @docker service create \
	# -d \
	# --name portainer \
	# --publish 9000:9000 \
	# portainer/portainer \
	# -H tcp://${MANAGER_IP}:2376
	$(MKDIR) -p data; \
	@docker service create \
	-d \
    --name portainer \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
	--mount type=bind,src=$$PWD/data,dst=/data \
    portainer/portainer \
	-H tcp://${MANAGER_IP}:2376

	# @bash ./scripts/docker-start-portainer.sh
install-portainer:
	$(MKDIR) -p data; \
	@docker service create \
    --detach=true \
    --name portainer \
    --publish 9000:9000 \
    --constraint 'node.role == manager' \
    --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
    --mount type=bind,src=$$PWD/data,dst=/data \
    portainer/portainer \
    -H unix:///var/run/docker.sock

install-viz:
	@docker service create \
	--detach=true \
	--publish=9190:8080/tcp \
	--limit-cpu 0.5 \
	--name=viz \
	--env PORT=9190 \
	--constraint=node.role==manager \
	--mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
	dockersamples/visualizer

install-seagull:
	@docker run -d \
	-p 10086:10086 \
	-v /var/run/docker.sock:/var/run/docker.sock \
	tobegit3hub/seagull

install-node-exporter-prometheus:
	docker run -d -p 9100:9100 \
	-v "/proc:/host/proc:ro" \
	-v "/sys:/host/sys:ro" \
	-v "/:/rootfs:ro" \
	--net="host" \
	quay.io/prometheus/node-exporter \
	--collector.procfs /host/proc \
	--collector.sysfs /host/sys \
	--collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"

# source: https://medium.com/@DazWilkin/docker-swarm-and-prometheus-fd19462f1bf8
install-node-exporter-nodez:
	docker service create \
	--name=nodez \
	--publish=9101:9100 \
	--mount=type=bind,source=/proc,target=/host/proc,readonly \
	--mount=type=bind,source=/sys,target=/host/sys,readonly \
	--mount=type=bind,source=/,target=/rootfs,readonly \
	--mode=global \
	dazwilkin/zero-exporter:1706202032 \
	-collector.sysfs /host/sys \
	-collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"

./bin/docker-compose-x86_64:
	curl -L https://github.com/docker/compose/releases/download/$(DOCKER_COMPOSE_VERSION)/docker-compose-`uname -s`-`uname -m` > ./bin/docker-compose-x86_64 && \
	chmod + ./bin/docker-compose-x86_64
	./bin/docker-compose-x86_64 version

./bin/docker-machine-x86_64:
	curl -L https://github.com/docker/machine/releases/download/$(DOCKER_MACHINE_VERSION)/docker-machine-`uname -s`-`uname -m` > ./bin/docker-machine-x86_64 && \
	chmod +x ./bin/docker-machine-x86_64
	./bin/docker-machine-x86_64 version

bootstrap-docker-toolbox: ./bin/docker-compose-x86_64 ./bin/docker-machine-x86_64

list:
	@$(MAKE) -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$$)/ {split($$1,A,/ /);for(i in A)print A[i]}' | sort

test:
	@docker --version

clean:
	$(RM) ./bin/docker-compose-x86_64
	$(RM) ./bin/docker-machine-x86_64

perf:
	@bash ./scripts/perf.sh

# Needed for elasticsearch
perf-es:
	$(DM) ssh swarm-manager sudo sysctl -w vm.max_map_count=262144
	$(DM) ssh node-01 sudo sysctl -w vm.max_map_count=262144
	$(DM) ssh node-02 sudo sysctl -w vm.max_map_count=262144
	$(DM) ssh node-03 sudo sysctl -w vm.max_map_count=262144

# This will start the services in the stack which is named monitor.
# This might take some time the first time as the nodes have
# to download the images.
# Also, you need to create the database named cadvisor in InfluxDB to store the metrics.
deploy-monitoring:
	@docker stack deploy -c docker-compose.monitoring.yml monitor
	sleep 60
	@bash ./scripts/create-influx-db.sh

# This will start the services in the stack named elk
deploy-logging:
	@docker stack deploy -c docker-compose.logging.yml elk

deploy-nginx:
	@docker stack deploy -c docker-compose.nginx.yml nginx

deploy-whoami:
	@docker stack deploy -c docker-compose.whoami.yml whoami

deploy-portainer:
	# @docker stack deploy -c docker-compose.portainer.yml portainer
	docker run -d \
		--name portainer \
		-p 9000:9000 \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		portainer/portainer

deploy-swarmpit:
	@docker stack deploy -c docker-compose.swarmpit.yml swarmpit

# NOTE: alternative docker stack ps monitor
list-services-swarm-monitoring:
	@docker stack services monitor

# NOTE: alternative docker stack ps monitor
list-services-swarm-logging:
	@docker stack services elk

# NOTE: alternative docker stack ps monitor
list-services-swarm-nginx:
	@docker stack services nginx

ps-monitoring-containers:
	@docker stack ps monitor

ps-nginx-containers:
	@docker stack ps nginx

ps-logging-containers:
	@docker stack ps elk

open-grafana:
	@bash ./scripts/open-grafana.sh

open-logstash:
	@bash ./scripts/open-logstash.sh

open-nginx:
	@bash ./scripts/open-nginx.sh

open-alertmanager:
	@bash ./scripts/open-alertmanager.sh

open-portainer:
	@bash ./scripts/open-portainer.sh

open-viz:
	@bash ./scripts/open-visualizer.sh

open-prometheus:
	@bash ./scripts/open-prometheus.sh

open-seagull:
	@bash ./scripts/open-seagull.sh

stop-logging:
	docker stack rm elk

stop-monitoring:
	docker stack rm monitor

stop-nginx:
	docker stack rm nginx

stop-portainer:
	docker stop portainer

stop-viz:
	@docker service rm viz

stop-whoami:
	@docker service rm whoami

stop-swarmpit:
	@docker service rm swarmpit

docker-service-ls:
	@docker service ls
