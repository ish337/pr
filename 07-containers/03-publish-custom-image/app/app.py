import requests
import urllib3
from flask import Flask, render_template_string

app = Flask(__name__)

# Proxmox and TikTok use self-signed certificates, don't print a warning for every check
urllib3.disable_warnings()

# Lab services: name and the URL that answers when the service is up
SERVICES = [
    ("Proxmox", "https://10.7.66.200:8006"),
    ("Grafana", "http://10.7.66.112:3000/api/health"),
    ("Prometheus", "http://10.7.66.112:9090/-/healthy"),
    ("Loki", "http://10.7.66.112:3100/ready"),
    ("pg-db node exporter", "http://10.7.66.111:9100/metrics"),
    ("Jenkins", "http://10.7.66.144:8080/login"),
    ("TikTok", "https://10.7.66.145"),
]

PAGE = """
<!doctype html>
<html>
<head>
  <title>Lab status</title>
  <style>
    body { font-family: sans-serif; margin: 40px; }
    td, th { padding: 6px 16px; text-align: left; }
    .up { color: green; }
    .down { color: red; }
  </style>
</head>
<body>
  <h1>Lab status</h1>
  <table>
    <tr><th>Service</th><th>URL</th><th>Status</th></tr>
    {% for name, url, up in results %}
    <tr>
      <td>{{ name }}</td>
      <td><a href="{{ url }}">{{ url }}</a></td>
      <td class="{{ 'up' if up else 'down' }}">{{ 'UP' if up else 'DOWN' }}</td>
    </tr>
    {% endfor %}
  </table>
</body>
</html>
"""


def is_up(url):
    try:
        response = requests.get(url, timeout=2, verify=False)
        return response.status_code < 400
    except requests.RequestException:
        return False


@app.route("/")
def index():
    results = [(name, url, is_up(url)) for name, url in SERVICES]
    return render_template_string(PAGE, results=results)


# For Docker or monitoring, shows that the app itself is running
@app.route("/health")
def health():
    return "ok"
