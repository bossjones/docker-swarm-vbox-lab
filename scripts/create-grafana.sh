#!/usr/bin/env bash

# source: https://github.com/grafana/grafana/issues/1789
# source: https://github.com/grafana/grafana/issues/1789#issuecomment-248309442

_GRAFANA_IP=$(docker-machine ip swarm-manager)


AddDataSourceCadvisor() {
  curl "http://${_GRAFANA_IP}:3000/api/datasources" \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary \
    '{"name":"influx","type":"InfluxDB","url":"http://influx:8086","access":"proxy","isDefault":true,"database":"cadvisor"}'
}

AddDataSourcePrometheus() {
  curl "http://${_GRAFANA_IP}:3000/api/datasources" \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary \
    '{"name":"Prometheus","type":"prometheus","url":"http://prometheus:9090","access":"proxy","isDefault":false,"database":"prometheus"}'
}
until AddDataSourcePrometheus; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'

until AddDataSourceCadvisor; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'

wait
