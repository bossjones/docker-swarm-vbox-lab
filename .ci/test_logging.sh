#!/usr/bin/env bash

# TODO: Verify that all endpoints are accessible ( We should probably use goss for this )
# TODO: Or, we can use jinja, or

# elasticsearch: node-01 (9200, 9300)
# logstash: node-02 (5044, 9600)
# logspout: global (8000:80)
# kibana: node-03 (8088:5601)

_SWARM_MANAGER_IP=$(docker-machine ip swarm-manager)
_NODE_1_IP=$(docker-machine ip node-01)
_NODE_2_IP=$(docker-machine ip node-02)
_NODE_3_IP=$(docker-machine ip node-03)

# while ! curl --retry 10 --retry-delay 5 -v http://0.0.0.0:8090 >/dev/null; do sleep 1; done

echo "elasticsearch:9200"
while ! curl --retry 10 --retry-delay 5 -v http://0.0.0.0:8090 >/dev/null; do sleep 1; done
