#!/bin/bash

set -euo pipefail

# Run on pg-db next to config.alloy: sudo ./install-agents.sh
MONITORING_IP="10.7.66.112"

# Metrics: node exporter on port 9100, open only for Prometheus on the monitoring VM
apt-get update
apt-get install -y prometheus-node-exporter
ufw allow from "$MONITORING_IP" to any port 9100 proto tcp

# Logs: Grafana Alloy from the Grafana apt repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor --yes -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y alloy

# Log files in /var/log belong to the adm group
usermod -aG adm alloy
cp config.alloy /etc/alloy/config.alloy
# The package doesn't enable alloy, without this it won't start after a reboot
systemctl enable alloy
systemctl restart alloy

echo "--- node exporter and alloy are running ---"
