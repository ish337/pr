# Infrastructure monitoring and logging

Prometheus, Loki and Grafana on a separate Proxmox VM, they collect metrics and logs from pg-db. Screenshots and output are in [outputs/](outputs/).

## How it works

- The monitoring VM (10.7.66.112) is created by [terraform/](terraform/), cloud-init installs Docker and starts [docker-compose.yml](terraform/files/docker-compose.yml) with Prometheus, Loki and Grafana.
- node exporter runs on both VMs, Prometheus scrapes it every 15 seconds, targets are in [prometheus.yml](terraform/files/prometheus.yml).
- Grafana Alloy on pg-db reads log files and pushes them to Loki, config is in [config.alloy](pg-db/config.alloy).
- Both agents on pg-db are installed by [install-agents.sh](pg-db/install-agents.sh), it also opens port 9100 in ufw only for the monitoring VM.
- Grafana gets Prometheus and Loki as data sources on start from [grafana-datasources.yml](terraform/files/grafana-datasources.yml).
- The agents on pg-db use about 46 MB of RAM (alloy 38 MB, node exporter 8 MB) and almost no CPU.

## Metrics

- CPU utilization: `node_cpu_seconds_total`
- Memory usage: `node_memory_MemAvailable_bytes`, `node_memory_MemTotal_bytes`
- Disk operations: `node_disk_reads_completed_total`, `node_disk_writes_completed_total`
- Network throughput: `node_network_receive_bytes_total`, `node_network_transmit_bytes_total`

## Logs

- `{job="syslog"}`: system log of pg-db.
- `{job="auth"}`: SSH logins and sudo, the security events.
- `{job="postgresql"}`: PostgreSQL log with failed logins and SQL errors.
- Example: `{job="postgresql"} |= "FATAL"` shows the failed DB logins.
- Example: `{job="auth"} |= "sudo"` shows who ran what as root.

## Dashboard

- Node Exporter Full (Grafana ID 1860), imported in Dashboards → New → Import.
- The VM is picked in the Instance field at the top, `10.7.66.111:9100` is pg-db.

## Alert

- High CPU: `100 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100` is above 80.
- Evaluated every 30s, fires after 1 minute above the threshold.
- Tested with two `yes > /dev/null` on pg-db, the rule went to Firing for 10.7.66.111.

## Retention

- Prometheus keeps metrics for 15 days (`--storage.tsdb.retention.time=15d`).
- Loki keeps logs for 7 days (`retention_period: 168h` in [loki.yml](terraform/files/loki.yml)).
- Data is in Docker volumes, so it stays after a container restart.

## Setup

1. Fill in `terraform/terraform.tfvars` from the example and run `terraform apply` in `terraform/`.
2. Copy `pg-db/` to pg-db and run `sudo ./install-agents.sh` there.
3. Log in to Grafana at http://10.7.66.112:3000, import dashboard 1860 and create the alert rule.

## Limitations

- The alert is only visible in Grafana, notifications are not sent because there is no SMTP or chat set up.
- The dashboard and the alert rule are made in the UI, not saved as files.
- Grafana and Loki use plain HTTP without TLS, fine for the lab network only.
