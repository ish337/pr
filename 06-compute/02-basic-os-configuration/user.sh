#!/bin/bash

# Usage: sudo ./user.sh create <username>
#        sudo ./user.sh passwd <username>
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: sudo ./user.sh create|passwd <username>"
  exit 1
fi

ACTION=$1
USERNAME=$2

if [ "$ACTION" = "create" ]; then
  useradd -m -s /bin/bash "$USERNAME"
  passwd "$USERNAME"
  id "$USERNAME"
elif [ "$ACTION" = "passwd" ]; then
  passwd "$USERNAME"
else
  echo "Unknown action: $ACTION"
  exit 1
fi
