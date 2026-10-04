# Observability data types

There are three main types of observability data. Examples are from the pg-db VM, the output is in [outputs/out.txt](outputs/out.txt).

## Metrics

Numbers measured over time, like CPU usage, free memory or disk I/O. They show how loaded the system is and are easy to draw as graphs.

- `vmstat` on the VM: CPU (us, sy, id) and memory (free, cache) every few seconds
- Proxmox VM Summary: CPU, memory and network graphs for the VM

## Logs

Text records of events with a timestamp, like a service start, an error or a failed login. They show what exactly happened and when.

- PostgreSQL log: `/var/log/postgresql/postgresql-16-main.log`
- systemd journal: `journalctl -u ssh`

## Traces

The path of one request through several services, with the time spent in each one. They are useful when an app is split into many services.

- Not collected on pg-db: it's a single database, there is no app that sends requests through several services. Tools for traces are Jaeger or OpenTelemetry.
