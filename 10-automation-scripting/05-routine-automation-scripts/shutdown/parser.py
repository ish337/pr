import re
import sys
from collections import defaultdict

LOG_FILE = r'/home/debian/log/ansible_shutdown.log'

def parse_and_group(filepath):
    buildings = defaultdict(list)
    
    pattern = re.compile(r'^\s*(10\.(1|2)\.\d{1,3}\.\d{1,3})\s+:.*ok=([1-9]\d*)')

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            for line in f:
                match = pattern.search(line)
                if match:
                    ip = match.group(1)
                    second = match.group(2)
                    
                    if second == '1':
                        buildings['Building A'].append(ip)
                    elif second == '2':
                        buildings['Building B'].append(ip)
                        
    except FileNotFoundError:
        return None

    return buildings

def format_output(data):
    if not data:
        return "There are no turned computers"

    output = []
    for building in sorted(data.keys()):
        ips = data[building]
        ips.sort(key=lambda x: [int(part) for part in x.split('.')])
        
        output.append(f" *{building}* (Turned off: {len(ips)}):")
        for i, ip in enumerate(ips, 1):
            output.append(f"{i}. {ip}")
        output.append("")

    return "\n".join(output).strip()

if __name__ == "__main__":
    results = parse_and_group(LOG_FILE)
    
    if results is None:
        print(f"No log file")
    else:
        print(format_output(results))
