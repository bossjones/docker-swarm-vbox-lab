#!/usr/bin/env bash

# source: https://github.com/grafana/grafana/issues/1789
# source: https://github.com/grafana/grafana/issues/1789#issuecomment-248309442

AddDataSourcePrometheus() {
  curl 'http://localhost:3000/api/datasources' \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary \
    '{"name":"Prometheus","type":"prometheus","url":"http://prometheus:9090","access":"proxy","isDefault":true}'
}
until AddDataSourcePrometheus; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'
wait
