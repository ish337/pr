# Nightly shutdown of computers

Two scripts in [shutdown/](shutdown/) that turn off the computers in two buildings every night and send the list of turned off computers to Telegram. Output is in [outputs/](outputs/).

## How it works

- cron starts [shutdown.sh](shutdown/shutdown.sh) every day at 22:00.
- shutdown.sh runs the ansible playbook for building B and then for building A, the output goes to `ansible_shutdown.log`.
- [parser.py](shutdown/parser.py) reads the PLAY RECAP part of the log and takes the hosts with `ok=1` or more, these were turned off.
- Hosts with `unreachable=1` are skipped, they were already off.
- The second octet of the IP is the building: `10.1.x.x` is building A, `10.2.x.x` is building B.
- shutdown.sh sends the parser's output to the Telegram chat with the bot API.

## Prerequisites

- ansible with the playbook and the inventories of both buildings.
- python3, the parser uses only the standard library.
- curl and a Telegram bot token with the chat id.

## Setup

```bash
cp shutdown.sh parser.py /home/debian/log/
cp telegram.env.example /home/debian/log/telegram.env
chmod 600 /home/debian/log/telegram.env
crontab -e
```

The cron line:

```
0 22 * * * /bin/bash /home/debian/log/shutdown.sh > /home/debian/log/cron_debug.log 2>&1
```

## parser.py

```bash
python3 parser.py                           # reads /home/debian/log/ansible_shutdown.log
python3 parser.py sample/ansible_shutdown.log
python3 parser.py --help
```

- Exit code 0: the message is printed, also when nothing was turned off.
- Exit code 1: the log file doesn't exist or can't be read, the error goes to stderr.
- [sample/](shutdown/sample/) has two logs for testing: one with turned off computers in both buildings, one where all hosts are unreachable.

## shutdown.sh

- Exit code 0: the message was sent.
- Exit code 1: telegram.env is missing or Telegram didn't accept the message.
- The ansible exit code doesn't stop the script, unreachable hosts are normal at night.
- If the parser fails, the message says that the log can't be read.
