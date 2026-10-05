# SSH access

SSH keys for the lab VMs and GitHub. Output and screenshots are in [outputs/](outputs/).

## Keys

- `lab_ed25519`: for the lab VMs, made for this task, with a passphrase.
- `id_ed25519`: for GitHub, with a passphrase, it's the key "arch" in GitHub → Settings → SSH and GPG keys (01.png).
- `proxmox_tf`: only for Terraform to upload cloud-init snippets to the Proxmox node, without a passphrase because Terraform can't type it.
- One key per purpose, so if one leaks only that access has to be changed.

## Key generation

```bash
ssh-keygen -t ed25519 -C "ish337 lab" -f ~/.ssh/lab_ed25519
```

- ed25519 keys are short and secure, the comment shows what the key is for.
- Private keys have 600 permissions and never leave ~/.ssh, only the .pub file is shared.

## Adding the key to a server

```bash
ssh-copy-id -i ~/.ssh/lab_ed25519.pub ubuntu@10.7.66.112
```

- For new VMs the public key goes in with cloud-init, `ssh_public_key` in terraform.tfvars.

## Connecting

The hosts are in `~/.ssh/config`:

```
Host monitoring
    HostName 10.7.66.112
    User ubuntu
    IdentityFile ~/.ssh/lab_ed25519

Host github.com
    User git
    IdentityFile ~/.ssh/id_ed25519
```

- `ssh monitoring` logs in as `ubuntu`, a normal user, `sudo` gives root when needed.
- To type the passphrase only once per session: `eval "$(ssh-agent -s)"` and `ssh-add ~/.ssh/lab_ed25519`.
- Git uses SSH with the remote `git@github.com:ish337/pr.git`.

## Server settings

- `passwordauthentication no`: only keys, a login without a key gets "Permission denied (publickey)".
- `permitrootlogin without-password`: root can't log in with a password, and root has no key, so the login is always as `ubuntu`.

## Port forwarding

```bash
ssh -L 9091:localhost:9090 monitoring
```

- While the session is open, Prometheus from the VM is on http://localhost:9091 (02.png).
- This way a service can be opened without opening its port to the network.

## If a key leaks

- Remove the public key from `~/.ssh/authorized_keys` on the servers and from GitHub.
- Generate a new key and add it again.
