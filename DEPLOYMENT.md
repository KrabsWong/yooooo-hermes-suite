# Deployment Guide

This guide covers a fresh production deployment of **Yooooo Hermes Suite** on a server.

## 1. Prerequisites

Before deployment, prepare:

- a Linux server with Docker and Docker Compose installed
- a domain name that resolves to the server public IP
- inbound firewall access for:
  - TCP `80`
  - TCP `443`
  - UDP `443` only if you want HTTP/3
- at least one supported model credential, such as `DEEPSEEK_API_KEY`

Recommended baseline for a cloud-API deployment:

- `2 vCPU`
- `4 GB RAM`
- `40 GB SSD`

## 2. Clone the repository

```bash
git clone git@github.com:KrabsWong/yooooo-hermes-suite.git
cd yooooo-hermes-suite
```

## 3. Prepare local-only files

```bash
cp env/compose.env.example env/compose.env
cp env/hermes.env.example data/hermes-home/.env
cp env/prod.env.example env/prod.env
cp config/config.yaml data/hermes-home/config.yaml
cp proxy/caddy/Caddyfile.example proxy/caddy/Caddyfile
```

Edit these files before first start:

- `env/compose.env`
- `env/prod.env`
- `data/hermes-home/.env`

Minimum values to review:

```env
# env/compose.env
UID=1000
GID=1000
HERMES_WORKSPACE=/absolute/path/to/workspace

# env/prod.env
HERMES_DOMAIN=hermes.example.com

# data/hermes-home/.env
DEEPSEEK_API_KEY=...
```

## 4. Optional: prepare off-host backup sync

If you want Cloudflare R2 and/or Tencent COS remote backups from day one:

```bash
cp env/remote-backup.env.example env/remote-backup.env
cp remote-backup/rclone.conf.example remote-backup/rclone.conf
```

Then edit:

- `env/remote-backup.env`
- `remote-backup/rclone.conf`

Recommended production setting:

```env
AUTO_REMOTE_BACKUP=true
REMOTE_BACKUP_SYNC_DELETE=false
```

## 5. Start production

```bash
./scripts/up-prod.sh
```

## 6. Validate deployment

```bash
./scripts/health-prod.sh
```

Then verify in a browser:

```text
https://your-domain.example
```

## 7. Routine operations

```bash
# View logs
./scripts/logs-prod.sh

# Create a backup
./scripts/backup-prod.sh

# Upgrade safely
./scripts/upgrade-prod.sh

# Stop the production stack
./scripts/down-prod.sh
```

## 8. Common deployment checks

### HTTPS does not come up

Check:

- the domain really resolves to this server
- ports `80` and `443` are open
- `env/prod.env` contains the correct `HERMES_DOMAIN`
- `proxy/caddy/Caddyfile` exists

### WebUI is up but the agent cannot answer

Check:

- `data/hermes-home/.env` contains a valid model provider key
- `data/hermes-home/config.yaml` selects a model/provider you can use
- `./scripts/logs-prod.sh hermes-agent` for startup or credential errors

### Do not expose these directly

In production, public ingress should be through Caddy only. Do not publish the Hermes Agent or WebUI ports directly unless you have a deliberate reason.
