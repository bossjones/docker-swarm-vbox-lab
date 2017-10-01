# docker-swarm-vbox-lab
lab to try out using docker swarm on virtualized environment using vagrant

# Lots of influence from
- https://github.com/deviantony/docker-elk

# Stack Overview( All using docker-swarm )
- Prometheus Server
- Prometheus Alertmanager
- Node Exporter
- Portainer
- Grafana
- Nginx reverse proxy with SSL/TLS [Let's encrypt certificate](https://letsencrypt.org/)
- ELK stack ( Elasticsearch, Logstash, Kibana )

# Future ( Fun things to try to get working )
- StackStorm [Event-driven automation](https://github.com/StackStorm/st2-docker)
- Bro IDS
- Redis/Zmq/RabbitMq ( Some sort of queue solution )
- zq [Kafka-based Job Queue for Python ](https://github.com/joowani/kq)
- etcd: [Distributed reliable key-value store for the most critical data of a distributed system](https://github.com/coreos/etcd)
- faas: [Functions as a Service (OpenFaaS)](https://github.com/alexellis/faas)
- opentracing: [distributed tracing and context propagation](https://github.com/opentracing)
- Zipkin
- Jaegar
- locustio
- Loki: [Simple, Distributed Tracing](https://github.com/weaveworks-experiments/loki)
- Vizceral: [WebGL visualization for displaying animated traffic graphs](https://github.com/Netflix/vizceral)
- [Vizceral Example](https://github.com/Netflix/vizceral-example)
- Jenkins: [For automation of tasks](https://github.com/jenkinsci/docker)
- Vault: [hashicorp secret management](https://github.com/hashicorp/docker-vault)
- [Augmented Traffic Control:](https://github.com/facebook/augmented-traffic-control)
- Facebook Osquery: [SQL powered operating system instrumentation, monitoring, and analytics.](https://github.com/kolide/docker-osquery/blob/master/ubuntu16-osquery/Dockerfile)
- Hubble: [Security compliance framework](https://github.com/hubblestack/hubble-salt)
- doorman: [osquery fleet manager](https://github.com/mwielgoszewski/doorman)
- ChaosMonkey: [resiliency tool that helps applications tolerate random instance failures](https://github.com/netflix/chaosmonkey)
- git-server-docker: [Git Server in Docker](https://github.com/jkarlosb/git-server-docker)
- gitlab-ce: [GitLab Community Edition docker image based on the Omnibus package](https://hub.docker.com/r/gitlab/gitlab-ce/)
# Research:

- https://www-public.tem-tsp.eu/~berger_o/docker/install-docker-machine-virtualbox.html
- https://unix.stackexchange.com/questions/269912/send-command-to-the-shell-via-makefile
- https://docs.docker.com/get-started/part3/
- https://stackoverflow.com/questions/7897549/make-ignores-my-python-bash-alias
- https://botleg.com/stories/monitoring-docker-swarm-with-cadvisor-influxdb-and-grafana/
- https://github.com/bvis/docker-prometheus-swarm/blob/master/docker-compose.logging.yml

# Recover after swarm reboot
- https://forums.docker.com/t/docker-worker-nodes-shown-as-down-after-re-start/22329/2
- https://github.com/moby/moby/issues/23828
- https://docs.docker.com/engine/swarm/admin_guide/#monitor-swarm-health
- https://docs.docker.com/engine/swarm/admin_guide/#run-manager-only-nodes

#

`export discotoken=<some-token>`

# How to fix 'Error response from daemon: 404 page not found'

Source: `DOCKER SWARM MODE SETUP WITH DOCKER MACHINE` - http://perica.zivkovic.nl/blog/setup-docker-swarm-with-docker-machine-do/


# Example output from creating a docker swarm

```
 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → ./bin/docker-machine-x86_64 env local
export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/malcolm/.docker/machine/machines/local"
export DOCKER_MACHINE_NAME="local"
# Run this command to configure your shell:
# eval $(./bin/docker-machine-x86_64 env local)

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → eval $(./bin/docker-machine-x86_64 env local)

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → make dm-ls
./bin/docker-machine-x86_64 ls
NAME                   ACTIVE   DRIVER         STATE     URL                         SWARM   DOCKER        ERRORS
dev                    -        vmwarefusion   Stopped                                       Unknown
local                  *        virtualbox     Running   tcp://192.168.99.100:2376           v17.06.2-ce
scarlett-1604-packer   -        generic        Stopped                                       Unknown

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → make bootstrap-swarm
./bin/docker-machine-x86_64 create -d virtualbox swarm-manager
Running pre-create checks...
Creating machine...
(swarm-manager) Copying /Users/malcolm/.docker/machine/cache/boot2docker.iso to /Users/malcolm/.docker/machine/machines/swarm-manager/boot2docker.iso...
(swarm-manager) Creating VirtualBox VM...
(swarm-manager) Creating SSH key...
(swarm-manager) Starting the VM...
(swarm-manager) Check network to re-create if needed...
(swarm-manager) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: ./bin/docker-machine-x86_64 env swarm-manager
./bin/docker-machine-x86_64 create -d virtualbox node-01
Running pre-create checks...
Creating machine...
(node-01) Copying /Users/malcolm/.docker/machine/cache/boot2docker.iso to /Users/malcolm/.docker/machine/machines/node-01/boot2docker.iso...
(node-01) Creating VirtualBox VM...
(node-01) Creating SSH key...
(node-01) Starting the VM...
(node-01) Check network to re-create if needed...
(node-01) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: ./bin/docker-machine-x86_64 env node-01
./bin/docker-machine-x86_64 create -d virtualbox node-02
Running pre-create checks...
Creating machine...
(node-02) Copying /Users/malcolm/.docker/machine/cache/boot2docker.iso to /Users/malcolm/.docker/machine/machines/node-02/boot2docker.iso...
(node-02) Creating VirtualBox VM...
(node-02) Creating SSH key...
(node-02) Starting the VM...
(node-02) Check network to re-create if needed...
(node-02) Waiting for an IP...
Waiting for machine to be running, this may take a few minutes...
Detecting operating system of created instance...
Waiting for SSH to be available...
Detecting the provisioner...
Provisioning with boot2docker...
Copying certs to the local machine directory...
Copying certs to the remote machine...
Setting Docker configuration on the remote daemon...
Checking connection to Docker...
Docker is up and running!
To see how to connect your Docker Client to the Docker Engine running on this virtual machine, run: ./bin/docker-machine-x86_64 env node-02
# ./bin/docker-machine-x86_64 create -d virtualbox node-03

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → MANAGER_IP=$(docker-machine ip swarm-manager)

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker swarm --help

Usage:  docker swarm COMMAND

Manage Swarm

Options:
      --help   Print usage

Commands:
  init        Initialize a swarm
  join        Join a swarm as a node and/or manager
  join-token  Manage join tokens
  leave       Leave the swarm
  unlock      Unlock swarm
  unlock-key  Manage the unlock key
  update      Update the swarm

Run 'docker swarm COMMAND --help' for more information on a command.

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker swarm join-token --help

Usage:  docker swarm join-token [OPTIONS] (worker|manager)

Manage join tokens

Options:
      --help     Print usage
  -q, --quiet    Only display token
      --rotate   Rotate join token

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → MANAGER_IP=$(./bin/docker-machine-x86_64 ip swarm-manager)

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → echo ${MANAGER_IP}
192.168.99.104

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → ./bin/docker-machine-x86_64 ssh swarm-manager docker swarm init --advertise-addr ${MANAGER_IP}
Swarm initialized: current node (9r8nhpx908lk2msh9odlge39v) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join --token SWMTKN-1-3qdkv66g9isfqftixhz34vxkawosw32vwjebgu0yprpxah5vms-0u8wxklm8ms8wcwxsrbu0rpla 192.168.99.104:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.


 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → WORKER_TOKEN=$(./bin/docker-machine-x86_64 ssh swarm-manager docker swarm join-token --quiet worker)

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → echo ${WORKER_TOKEN}}
SWMTKN-1-3qdkv66g9isfqftixhz34vxkawosw32vwjebgu0yprpxah5vms-0u8wxklm8ms8wcwxsrbu0rpla}

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → ./bin/docker-machine-x86_64 ssh node-01 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
This node joined a swarm as a worker.

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → ./bin/docker-machine-x86_64 ssh node-02 docker swarm join --token ${WORKER_TOKEN} ${MANAGER_IP}:2377
This node joined a swarm as a worker.

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → eval "$(./bin/docker-machine-x86_64 env swarm-manager)"

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
9r8nhpx908lk2msh9odlge39v *   swarm-manager       Ready               Active              Leader
lcar141vjpbmp8robql4sy6za     node-02             Ready               Active
lgmpnbaga2yiowzzwecblreqo     node-01             Ready               Active

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → echo ${MANAGER_IP}
192.168.99.104

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker service create \
> -d \
> --name portainer \
> --publish 9000:9000 \
> portainer/portainer \
> -H tcp://${MANAGER_IP}:2376
k6ue1in8da665mraodqmnid7a

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
9r8nhpx908lk2msh9odlge39v *   swarm-manager       Ready               Active              Leader
lcar141vjpbmp8robql4sy6za     node-02             Ready               Active
lgmpnbaga2yiowzzwecblreqo     node-01             Ready               Active

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker service --help

Usage:  docker service COMMAND

Manage services

Options:
      --help   Print usage

Commands:
  create      Create a new service
  inspect     Display detailed information on one or more services
  logs        Fetch the logs of a service or task
  ls          List services
  ps          List the tasks of one or more services
  rm          Remove one or more services
  scale       Scale one or multiple replicated services
  update      Update a service

Run 'docker service COMMAND --help' for more information on a command.

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE                 PORTS
k6ue1in8da66        portainer           replicated          1/1                 portainer/portainer   *:9000->9000/tcp

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → gs
On branch master
Your branch is up-to-date with 'origin/master'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

        modified:   Makefile
        modified:   README.md

no changes added to commit (use "git add" and/or "git commit -a")

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master U:2 ✗| → git add .

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master S:2 ✗| → git commit -m "Chg: portainer"
[master 4609578] Chg: portainer
 2 files changed, 44 insertions(+)

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master ↑1 ✓| → gp
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (4/4), done.
Writing objects: 100% (4/4), 1.20 KiB | 1.20 MiB/s, done.
Total 4 (delta 3), reused 0 (delta 0)
remote: Resolving deltas: 100% (3/3), completed with 3 local objects.
To github.com:bossjones/docker-swarm-vbox-lab.git
   6e63286..4609578  master -> master

 |2.2.3|   Malcolms-MBP-3 in ~/dev/bossjones/docker-swarm-vbox-lab
± |master ✓| →
```

# Dashboard for Grafana

Borrowed from https://github.com/botleg/swarm-monitoring !

Source: https://github.com/botleg/swarm-monitoring/blob/master/dashboard.json

# Prometheus

Borrowed from https://github.com/vegasbrianc/prometheus

# SSL configuration example

- https://github.com/danguita/prometheus-monitoring-stack

# SMTP server for alertmanager

- https://hub.docker.com/r/marvambass/versatile-postfix/

# networking external example

- https://github.com/bvis/docker-prometheus-swarm/blob/master/docker-compose.logging.yml

# networking on swarm classic

- [Multi-host networking with standalone swarms](https://docs.docker.com/engine/userguide/networking/overlay-standalone-swarm/)

# Install Grafana Plugins ( grafana-cli admin )
- http://docs.grafana.org/plugins/installation/
- http://docs.grafana.org/administration/cli/

# Consul setup and config
- https://medium.com/zendesk-engineering/making-docker-and-consul-get-along-5fceda1d52b9
- https://www.consul.io/docs/guides/consul-containers.html
- https://blog.octo.com/en/how-does-it-work-docker-part-1-swarm-general-architecture/


# Networking problems
- https://github.com/docker/compose/issues/2908
- https://docs.docker.com/v17.06/compose/compose-file/#external-1

Example: In the example below, proxy is the gateway to the outside world. Instead of attempting to create a network called [projectname]_outside, Compose will look for an existing network simply called outside and connect the proxy service’s containers to it.

```
version: '2'

services:
  proxy:
    build: ./proxy
    networks:
      - outside
      - default
  app:
    build: ./app
    networks:
      - default

networks:
  outside:
    external: true
```

- https://blog.octo.com/en/how-does-it-work-docker-part-3-load-balancing-service-discovery-and-security/

- LOOK AT ME: Service is not DNS resolvable from another one if containers run on different nodes https://github.com/docker/swarmkit/issues/1429

- https://github.com/docker/swarmkit/issues/1716
- https://github.com/nlandolfi/mixer/blob/75ecdd0ad2959b0088ea75810ed1755b83e74490/deploy/kube/conf/import_dashboard.sh

# IOT Solution
- https://medium.com/@DazWilkin/docker-swarm-and-prometheus-fd19462f1bf8


# Node file Service Discovery
- https://github.com/SphericalElephant/ansible-role-prometheus-node-exporter/blob/master/defaults/main.yml

`-collectors.enabled=conntrack,diskstats,entropy,filefd,filesystem,loadavg,mdadm,meminfo,netdev,netstat,sockstat,stat,textfile,time,uname,vmstat`

**This is Ansible FYI:**

```
prometheus_node_exporter_parameters:
  - "-collectors.enabled={{ prometheus_node_exporter_collectors_enable | join(',') }}"
  - "-web.listen-address={{ prometheus_node_exporter_web_listen_address }}"
  - '-log.level=info'
  - '-collector.diskstats.ignored-devices=^(ram|loop|fd)\d+$'
  - '-collector.filesystem.ignored-mount-points=^/(sys|proc|dev|run)($|/)'
  - '-collector.netdev.ignored-devices="{{ prometheus_node_exporter_collector_netdev_ignored_devices }}"'
  - '-collector.textfile.directory=/var/lib/prometheus/node-exporter'
  ```
