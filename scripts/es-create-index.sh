#!/usr/bin/env bash

set -x

export ES_IP=`docker-machine ip node-01`
export URL_BASE="http://${ES_IP}:9200/.kibana"

# Run this command to create a Logstash index pattern:
curl -XPUT -D- ${URL_BASE}'/index-pattern/logstash-*' \
    -H 'Content-Type: application/json' \
    -d '{"title" : "logstash-*", "timeFieldName": "@timestamp", "notExpandable": true}'

# This command will mark the Logstash index pattern as the default index pattern:
curl -XPUT -D- ${URL_BASE}'/config/5.6.1' \
    -H 'Content-Type: application/json' \
    -d '{"defaultIndex": "logstash-*"}'
