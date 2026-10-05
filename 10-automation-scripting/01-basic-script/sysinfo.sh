#!/bin/bash

# Prints basic info about this machine
set -euo pipefail

echo "Date:   $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host:   $(uname -n)"
echo "Uptime: $(uptime -p)"
echo "CPU:    $(nproc) cores, load $(cut -d ' ' -f1-3 /proc/loadavg)"
echo

free -h
echo

df -h /
