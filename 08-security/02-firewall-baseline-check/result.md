# Firewall check: pg-db

Checked ufw on pg-db against [baseline.md](baseline.md), output is in [outputs/out.txt](outputs/out.txt).

1. Firewall is active and starts on boot: ok
2. Incoming is denied by default: ok
3. Outgoing is allowed by default: ok
4. SSH 22/tcp is allowed: ok
5. 5432/tcp only from 10.7.0.0/16: **missing**, right now 5432 is open to everyone (Anywhere, IPv4 and IPv6)
6. Logging is on: ok

Everything matches except rule 5, it needs to be fixed.
