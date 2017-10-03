**SOURCE: https://airtame.engineering/practical-services-monitoring-with-prometheus-and-docker-30abd3cf9603**

- Node Exporter — Runs on each EC2 instance as a daemon and exposes system metrics like I/O, memory and CPU.

- Cloud Metrics Exporter — Custom exporter, written in-house, that shows us some important metrics by querying production databases.

- MySQLd Exporter — One of these per MySQL instance. Queries each environment’s database instances.

- Blackbox Exporter — Blackbox monitoring can be seen as “monitoring from outside”. It simply cares whether the instance is up or down.

- cAdvisor — Exposes resource usage data and performance characteristics of running containers.
