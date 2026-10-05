#!/bin/bash

# Usage: sudo ./user.sh create <username> [group]
#        sudo ./user.sh passwd <username>
set -euo pipefail

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
  echo "Usage: sudo ./user.sh create|passwd <username> [group]"
  exit 1
fi

ACTION=$1
USERNAME=$2
# Optional, an existing group for the new user, e.g. sudo
GROUP=${3:-}

if [ "$ACTION" = "create" ]; then
  useradd -m -s /bin/bash "$USERNAME"
  if [ -n "$GROUP" ]; then
    usermod -aG "$GROUP" "$USERNAME"
  fi
  passwd "$USERNAME"
  id "$USERNAME"
elif [ "$ACTION" = "passwd" ]; then
  passwd "$USERNAME"
else
  echo "Unknown action: $ACTION"
  exit 1
fi
