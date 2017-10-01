.PHONY: test clean

# https://stackoverflow.com/questions/7897549/make-ignores-my-python-bash-alias

DOCKER_VERSION := 17.05.0-ce
DOCKER_MACHINE_VERSION := v0.12.2
DOCKER_COMPOSE_VERSION := 1.16.1

MKDIR = mkdir
DM = ./bin/docker-machine-x86_64
DC = ./bin/docker-compose-x86_64
DOCKVIZ = docker run -it --rm -v /var/run/docker.sock:/var/run/docker.sock nate/dockviz

# docker version manager ( this doesnt work I think )
bootstrap-dvm:
	@bash ./scripts/bootstrap-dvm.sh

bootstrap-swarm-local:
	$(DM) create -d virtualbox local
	# eval $(./bin/docker-machine-x86_64 env local)

# NOTE: Based on
# http://perica.zivkovic.nl/blog/setup-docker-swarm-with-docker-machine-do/
bootstrap-swarm:
	$(DM) create -d virtualbox --virtualbox-memory 4096 --virtualbox-cpu-count 2 swarm-manager
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

docker-clean:
	@docker rm -v $$(docker ps --no-trunc -a -q); docker rmi $$(docker images -q --filter "dangling=true")

# source: https://unix.stackexchange.com/questions/269912/send-command-to-the-shell-via-makefile
env-dm-local:
	echo $$(./bin/docker-machine-x86_64 env local) > ./dm-local-env
	@echo "Run this command to configure your shell: # source ./dm-local-env"

deploy-consul:
	docker run -d \
	--name consul \
	-p "8500:8500" \
	-h "consul" \
	--rm \
	consul agent -server -bootstrap

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

create-monitoring-network:
	docker network create --driver overlay --subnet=10.0.9.0/24 monitoring
	docker network ls

perf:
	@bash ./scripts/perf.sh

# Needed for elasticsearch
perf-es:
	$(DM) ssh swarm-manager sudo sysctl -w vm.max_map_count=262144
	$(DM) ssh node-01 sudo sysctl -w vm.max_map_count=262144
	$(DM) ssh node-02 sudo sysctl -w vm.max_map_count=262144
	$(DM) ssh node-03 sudo sysctl -w vm.max_map_count=262144
	# TODO: Make sure we do a check to see if this is in there or not
	# FIXME: Make sure we do a check to see if this is in there or not
	# Make it perminent
	# $(DM) ssh swarm-manager echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
	# $(DM) ssh node-01 echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
	# $(DM) ssh node-02 echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
	# $(DM) ssh node-03 echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf

dockviz-containers:
	$(DOCKVIZ) containers -d | dot -Tpng -o images/containers.png

dockviz-images:
	$(DOCKVIZ) images --dot | dot -Tpng -o images/images.png

dockviz-images-label:
	$(DOCKVIZ) images --dot --only-labelled | dot -Tpng -o images/images_label.png

dockviz-image-tree:
	$(DOCKVIZ) images -t

dockviz-image-tree-labeled:
	$(DOCKVIZ) images -t -l

dockviz-image-tree-incremental:
	$(DOCKVIZ) images -t -i

# This will start the services in the stack which is named monitor.
# This might take some time the first time as the nodes have
# to download the images.
# Also, you need to create the database named cadvisor in InfluxDB to store the metrics.
# deploy-monitoring: create-influx create-grafana
deploy-monitoring:
	@docker stack deploy -c docker-compose.monitoring.yml monitor
	# sleep 60
	@bash ./scripts/create-influx-db.sh
	@bash ./scripts/create-grafana.sh

deploy-viz: install-viz

create-influx:
	@bash ./scripts/create-influx-db.sh

# This will start the services in the stack named elk
deploy-logging:
	@docker stack deploy -c docker-compose.logging.yml elk

deploy-nginx:
	@docker stack deploy -c docker-compose.nginx.yml nginx

deploy-whoami:
	@docker stack deploy -c docker-compose.whoami.yml whoami

deploy-logspout:
	@docker stack deploy -c docker-compose.logspout.yml logspout

deploy-portainer:
	# @docker stack deploy -c docker-compose.portainer.yml portainer
	docker run -d \
		--name portainer \
		-p 9000:9000 \
		--privileged \
		-v /var/run/docker.sock:/var/run/docker.sock \
		portainer/portainer

# source: https://oliverveits.wordpress.com/2016/11/02/how-to-set-up-docker-monitoring-via-cadvisor-influxdb-and-grafana/
deploy-swarmpit:
	@docker stack deploy -c docker-compose.swarmpit.yml swarmpit

deploy-stress-test:
	@docker run --rm -it petarmaric/docker.cpu-stress-test

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

open-influxdb:
	@bash ./scripts/open-influxdb.sh

open-cadvisor:
	@bash ./scripts/open-cadvisor.sh

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

open-elasticsearch:
	@bash ./scripts/open-elasticsearch.sh

open-head-plugin:
	@bash ./scripts/open-head-plugin.sh

open-seagull:
	@bash ./scripts/open-seagull.sh

open-kibana:
	@bash ./scripts/open-kibana.sh

open-node-exporter:
	@bash ./scripts/open-node-exporter.sh

open: open-prometheus open-viz open-portainer open-nginx open-logstash open-grafana open-kibana

open-monitoring: open-influxdb open-grafana open-cadvisor open-node-exporter

open-logging: open-kibana open-elasticsearch open-head-plugin open-elasticsearch-metrics

# source: https://github.com/vvanholl/elasticsearch-prometheus-exporter
# http://<your_server_address>:9200/_prometheus/metrics
open-elasticsearch-metrics:
	@bash ./scripts/open-elasticsearch-metrics.sh

direnv-rc:
	direnv allow .

dm-start-all:
	docker-machine start local
	docker-machine start swarm-manager
	docker-machine start node-01
	docker-machine start node-02
	docker-machine start node-03

dm-stop-all:
	docker-machine stop local
	docker-machine stop swarm-manager
	docker-machine stop node-01
	docker-machine stop node-02
	docker-machine stop node-03

create-grafana:
	@bash ./scripts/create-grafana.sh

es-create-index:
	@bash ./scripts/es-create-index.sh

scan-with-nmap:
	@bash ./scripts/scan-with-nmap.sh

create-elasticsearch-index: es-create-index

stop-logging:
	docker stack rm elk

stop-monitoring:
	docker stack rm monitor

stop-nginx:
	docker stack rm nginx

stop-logspout:
	docker stack rm logspout

stop-portainer: docker-clean
	docker stop portainer

stop-viz:
	@docker service rm viz

# @docker service rm whoami
stop-whoami:
	@docker stack rm whoami

stop-swarmpit:
	@docker service rm swarmpit

stop: stop-logging stop-monitoring

docker-service-ls:
	@docker service ls

start-docker-machines:
	@docker-machine start local
	@docker-machine start swarm-manager
	@docker-machine start node-01
	@docker-machine start node-02
	@docker-machine start node-03

regenerate-certs-docker-machines:
	@docker-machine regenerate-certs -f local
	@docker-machine regenerate-certs -f swarm-manager
	@docker-machine regenerate-certs -f node-01
	@docker-machine regenerate-certs -f node-02
	@docker-machine regenerate-certs -f node-03

# source: https://docs.docker.com/machine/drivers/virtualbox/
# a06cd926f5855d4f21fb4bc9978a35312f815fbda0d0ef7fdc846861f4fc4600 *ubuntu-16.04.3-server-amd64.iso
create-docker-machine-xenial:
	docker-machine create -d virtualbox \
	--virtualbox-memory 4096 \
	--virtualbox-cpu-count 2 \
	--virtualbox-boot2docker-url http://releases.ubuntu.com/16.04/ubuntu-16.04.3-server-amd64.iso \
	swarm-manager-xenial

	docker-machine create -d virtualbox \
	--virtualbox-boot2docker-url http://releases.ubuntu.com/16.04/ubuntu-16.04.3-server-amd64.iso \
	local-xenial

	docker-machine create -d virtualbox \
	--virtualbox-boot2docker-url http://releases.ubuntu.com/16.04/ubuntu-16.04.3-server-amd64.iso \
	node-xenial-01

	docker-machine create -d virtualbox \
	--virtualbox-boot2docker-url http://releases.ubuntu.com/16.04/ubuntu-16.04.3-server-amd64.iso \
	node-xenial-02

	docker-machine create -d virtualbox \
	--virtualbox-boot2docker-url http://releases.ubuntu.com/16.04/ubuntu-16.04.3-server-amd64.iso \
	node-xenial-03

reinit-docker-swarm-cluster:
	@docker swarm leave --force
