#!/bin/bash

# Turns off the computers in both buildings with ansible and sends
# the list of turned off computers to Telegram. Runs from cron at 22:00
#
# No -e here: ansible-playbook exits with 4 when some hosts are unreachable,
# that's normal at night, and the message must be sent anyway
set -uo pipefail

SCRIPT_DIR=/home/debian/log
LOG=$SCRIPT_DIR/ansible_shutdown.log
PLAYBOOK=/home/debian/ansible/playbooks/shutdown_hosts.yaml
HOSTS=/home/debian/ansible/hosts

/usr/bin/ansible-playbook "$PLAYBOOK" -i "$HOSTS/building_b/building_b" > "$LOG"
/usr/bin/ansible-playbook "$PLAYBOOK" -i "$HOSTS/building_a/building_a" >> "$LOG"

# If the log can't be read, send that instead of an empty message
if ! MESSAGE=$(/usr/bin/python3 "$SCRIPT_DIR/parser.py" "$LOG"); then
  MESSAGE="Shutdown: can't read $LOG, check the ansible server"
fi

# TOKEN and CHAT_ID are kept out of the script, see telegram.env.example
if [ ! -f "$SCRIPT_DIR/telegram.env" ]; then
  echo "Error: $SCRIPT_DIR/telegram.env not found, the message was not sent"
  exit 1
fi
source "$SCRIPT_DIR/telegram.env"

# --fail-with-body prints Telegram's answer and returns an error when it says no
if ! curl -sS --fail-with-body -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
  -d chat_id="${CHAT_ID}" \
  -d parse_mode="Markdown" \
  -d text="$MESSAGE"; then
  echo "Error: the message was not sent to Telegram"
  exit 1
fi
