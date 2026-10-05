# Support existing CI and deployment flows

A new Health check stage in the Jenkins pipeline of the Tiktok project (job tiktok). Screenshots and the build log are in [outputs/](outputs/).

## What was added

- Stage "Health check" after "Deploy TikTok on remote server" in `tools/Jenkins.jenkinsfile`.
- It runs `docker exec api curl -f http://localhost:8080/health`, the same check as the api healthcheck in compose.server.yaml.
- Then `curl -fkI https://localhost` checks that the site answers on 443.
- If one of the checks fails, the stage and the whole build are red.
- Commit: "Add health check stage to Jenkins pipeline".
- My PR to develop: https://github.com/fraspess/Tiktok_Clone/pull/199, it went to main with https://github.com/fraspess/Tiktok_Clone/pull/200.

## Why

- Deploy only runs `docker compose up -d`, so the build was green even if the api or the site didn't work after it.
- Now a green build means the app really answers after the deploy.

## How to run

- The pipeline starts by itself, Jenkins polls main every minute (Poll SCM).
- Or Jenkins → tiktok → Build Now.
- The result is in Pipeline Steps and Console Output of the build, Health check prints "Healthy" and "HTTP/1.1 200 OK".

## Outputs

- 01.png: the pipeline before, build #5 with Checkout, Build and Deploy.
- 02.png: build #6 after the merge, with the new Health check stage, all green.
- out.txt: console log of build #6, started by an SCM change.
