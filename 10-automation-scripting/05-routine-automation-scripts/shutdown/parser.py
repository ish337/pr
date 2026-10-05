import argparse
import re
import sys
from collections import defaultdict
from pathlib import Path

DEFAULT_LOG = "/home/debian/log/ansible_shutdown.log"

# A host line from PLAY RECAP, ok=1 or more means the shutdown task worked.
# The second octet of the IP is the building
PATTERN = re.compile(r"^\s*(10\.(1|2)\.\d{1,3}\.\d{1,3})\s+:.*ok=([1-9]\d*)")
BUILDINGS = {"1": "Building A", "2": "Building B"}


def parse_and_group(log_file):
    buildings = defaultdict(list)

    with log_file.open(encoding="utf-8") as f:
        for line in f:
            match = PATTERN.search(line)
            if match:
                ip = match.group(1)
                second = match.group(2)
                buildings[BUILDINGS[second]].append(ip)

    return buildings


def format_output(data):
    if not data:
        return "No computers were turned off"

    output = []
    for building in sorted(data):
        # Sort by numbers, so 10.1.1.2 goes before 10.1.1.10
        ips = sorted(
            data[building], key=lambda ip: [int(part) for part in ip.split(".")]
        )

        output.append(f"*{building}* (Turned off: {len(ips)}):")
        for i, ip in enumerate(ips, 1):
            output.append(f"{i}. {ip}")
        output.append("")

    return "\n".join(output).strip()


def main():
    arg_parser = argparse.ArgumentParser(
        description="Makes a Telegram message with the computers that ansible turned off"
    )
    arg_parser.add_argument(
        "log_file",
        nargs="?",
        default=DEFAULT_LOG,
        help=f"ansible-playbook output, default {DEFAULT_LOG}",
    )
    args = arg_parser.parse_args()

    log_file = Path(args.log_file)
    if not log_file.is_file():
        print(f"Error: log file {log_file} not found", file=sys.stderr)
        sys.exit(1)

    try:
        print(format_output(parse_and_group(log_file)))
    except PermissionError:
        print(f"Error: no permission to read {log_file}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
