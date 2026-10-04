# Firewall baseline: pg-db

What ufw on pg-db should have:

1. Firewall is active and starts on boot
2. Incoming is denied by default
3. Outgoing is allowed by default
4. SSH 22/tcp is allowed
5. 5432/tcp is allowed only from 10.7.0.0/16
6. Logging is on
