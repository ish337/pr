# Maintain infrastructure configuration

A change in the Terraform for the monitoring VM in [05-observability/04-infra-monitoring-logging/terraform](../../05-observability/04-infra-monitoring-logging/terraform/). Output and screenshots are in [outputs/](outputs/).

## What changed

- New variable `environment` in variables.tf, default `lab`, only lowercase letters, numbers and `-` are allowed.
- The VM gets the environment as a tag and in the description (Notes in Proxmox).
- terraform.tfvars.example has `environment = "lab"`.

## Why

- The tags were hardcoded in main.tf, so a dev or test copy of the VM would look the same as lab in Proxmox.
- Now the environment is set in terraform.tfvars and the code stays the same for every environment.
- The Notes say that the VM is managed by Terraform, so nobody changes it by hand in the UI.

## How to test

- `terraform fmt -check && terraform validate` checks the code.
- `terraform plan` is the dry run, it showed 1 to change (tags and description) and nothing replaced.
- `terraform apply` took 2 seconds, without a reboot.
- A second `terraform plan` shows "No changes", so a repeated run changes nothing.
- `terraform plan -var environment=test` changes only lab to test, another environment needs only another value.
- 01.png is the VM before (tags grafana, monitoring), 02.png is after (tags grafana, lab, monitoring and the Notes).

## Rollback

- `git revert <commit>` and `terraform apply`, the lab tag and the description are removed.

## Troubleshooting

- `terraform state list` shows what Terraform manages.
- If `terraform plan` shows changes when the code didn't change, somebody changed the VM by hand.
- In install-agents.sh I added `systemctl enable alloy`, because the package doesn't enable it and alloy didn't start after a reboot.
