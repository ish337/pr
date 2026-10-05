#!/bin/bash

TOKEN=""
CHAT_ID=""

/usr/bin/ansible-playbook /home/debian/ansible/playbooks/shutdown_hosts.yaml -i /home/debian/ansible/hosts/building_b/building_b > /home/debian/log/ansible_shutdown.log

/usr/bin/ansible-playbook /home/debian/ansible/playbooks/shutdown_hosts.yaml -i /home/debian/ansible/hosts/building_a/building_a >> /home/debian/log/ansible_shutdown.log

MESSAGE=$(/usr/bin/python3 /home/debian/log/parser.py)

curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
    -d chat_id="${CHAT_ID}" \
    -d parse_mode="Markdown" \
    -d text="$MESSAGE" 2>&1
