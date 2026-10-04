# Deploy and configure a service on OS level: PostgreSQL

PostgreSQL 16 server on an Ubuntu 24.04 VM in Proxmox. It is the database and listens on port 5432.

- FQDN: `ish-pgdb.duckdns.org` → `10.7.66.111`
- Code: [`01-databases/03-provision-db-instance/terraform/`](../../01-databases/03-provision-db-instance/terraform/)
- Evidence: [`outputs/`](outputs/)

## Installation

Fully scripted, no manual steps on the VM:

1. Terraform (`bpg/proxmox` provider) downloads the Ubuntu cloud image and creates the VM with a static IP.
2. cloud-init installs `postgresql` from the official Ubuntu repository and runs `setup-db.sh`.
3. `setup-db.sh` changes the config, creates the `appdb` database and the `app_user` role, and loads the Northwind sample data.

```bash
cd 01-databases/03-provision-db-instance/terraform
cp terraform.tfvars.example terraform.tfvars   # fill in Proxmox, network, SSH key, DB password
terraform init
terraform apply
```

## Service user and OS integration

- **User:** `postgres` (uid 109), a system user created by the package. It is not in the `sudo` group, and all server processes run as it.
- **systemd:** the server runs as `postgresql@16-main.service`, started by `postgresql.service` (`enabled`), so it comes up on boot.

## Configuration changes

| File | Change | Why |
|---|---|---|
| `/etc/postgresql/16/main/conf.d/10-listen.conf` | `listen_addresses = '*'` | the default listens on localhost only |
| `/etc/postgresql/16/main/pg_hba.conf` | `host all all 0.0.0.0/0 scram-sha-256` | allow password logins from other machines |
| database | `appdb`, role `app_user` with `CONNECT` and `SELECT/INSERT/UPDATE/DELETE` | application access without schema changes or superuser rights |

## Testing

| Check | Command | Result |
|---|---|---|
| FQDN resolves | `getent hosts ish-pgdb.duckdns.org` | `10.7.66.111` |
| Connection via FQDN | DBeaver, host `ish-pgdb.duckdns.org` | Connected, `01.png` |
| Setup reproduces on a clean VM | `terraform destroy` + `terraform apply` | `Apply complete! Resources: 3 added`, `02.png` |
| Dedicated user | `id postgres` | system user, not in `sudo` |
| Service runs under that user | `systemctl status postgresql@16-main`, `ps aux \| grep postgres` | `active (running)`, processes owned by `postgres` |
| Listens on its port | `ss -tln \| grep 5432` | `0.0.0.0:5432` |
| Healthy logs | `sudo tail /var/log/postgresql/postgresql-16-main.log` | `ready to accept connections`, no errors |
| Network | `ping google.com`, `ping 10.7.66.200` | external and internal network reachable |
| Starts after reboot | `sudo reboot`, then `uptime` and `systemctl status` | `up 1 min`, service `active (running)` |

All command output is in [`outputs/out.txt`](outputs/out.txt).

## Limitations

- `pg_hba.conf` accepts any address. The VM is only reachable inside the LAN or over VPN, so this is acceptable for a lab, but not for production.
- The DuckDNS record was set by hand in the DuckDNS web UI.
