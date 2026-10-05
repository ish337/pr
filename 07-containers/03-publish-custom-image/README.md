# Lab status page in a container

A small Flask app that checks the services in my lab and shows them as UP or DOWN. Code is in [app/](app/), output and screenshots are in [outputs/](outputs/).

## What it does

- `/` checks Proxmox, Grafana, Prometheus, Loki, the node exporter on pg-db, Jenkins and TikTok, and shows a table with links.
- A service is UP when its URL answers with a status below 400 in 2 seconds.
- `/health` returns `ok`, it shows that the app itself is running.
- The list of services is in `SERVICES` in [app.py](app/app.py).

## Image

- Base image: `python:3.12-slim`.
- Dependencies from [requirements.txt](app/requirements.txt): flask, requests and gunicorn.
- requirements.txt is copied before app.py, so the pip layer is cached when only the code changes.
- The app runs as the user `app`, not root, with gunicorn on port 5000.
- Registry: Docker Hub, `ish337/lab-status:1.0`.

## Build and run

```bash
cd app
sudo docker build -t lab-status .
sudo docker run -d --name lab-status -p 8080:5000 lab-status
curl localhost:8080/health
```

The page is on http://<host>:8080.

## Push and pull

```bash
sudo docker login -u ish337
sudo docker tag lab-status ish337/lab-status:1.0
sudo docker push ish337/lab-status:1.0
sudo docker logout
```

- Login is with a Docker Hub personal access token (Read & Write), not with the password.
- `docker logout` removes the token from the machine after the push.

Run on any machine with Docker, the image is pulled from Docker Hub:

```bash
sudo docker run -d --name lab-status -p 8080:5000 ish337/lab-status:1.0
```

## Outputs

- 01.png: the page, all services UP.
- 02.png: I stopped the TikTok agent VM (105) in Proxmox.
- 03.png: the page shows TikTok as DOWN.
- 04.png: the image with the 1.0 tag on Docker Hub.
- out.txt: curl through the port, push, and the run after deleting the local image.
