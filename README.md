# Yooooo Hermes Suite

A Docker-based deployment repository for running **Hermes Agent** and **Hermes WebUI** together while keeping host dependencies minimal.

## Layout

- `compose/` — Docker Compose stack definition
- `env/` — tracked examples plus local compose settings
- `config/` — tracked Hermes config template
- `data/hermes-home/` — local runtime state, secrets, sessions, logs, and databases (**gitignored**)
- `scripts/` — convenience commands for lifecycle and backup
- `proxy/caddy/` — production reverse-proxy template

## First-time setup

```bash
cp env/compose.env.example env/compose.env
cp env/hermes.env.example data/hermes-home/.env
cp config/config.yaml data/hermes-home/config.yaml
```

Then edit:

- `env/compose.env`
- `data/hermes-home/.env`

## Start

```bash
./scripts/up.sh
```

Open:

- WebUI: `http://127.0.0.1:8787`
- Hermes API gateway: `http://127.0.0.1:8642`

## Stop

```bash
./scripts/down.sh
```

## Logs

```bash
./scripts/logs.sh
```

## Backup local Hermes state

```bash
./scripts/backup.sh
```

## Security model

Tracked files are templates only. Real secrets and runtime state stay under `data/hermes-home/` and are intentionally excluded from Git.


## Production deployment

Production adds **Caddy** as the public entrypoint while keeping Hermes Agent and WebUI on the private Docker network.

### 1. Prepare local-only files

```bash
cp env/compose.env.example env/compose.env
cp env/hermes.env.example data/hermes-home/.env
cp env/prod.env.example env/prod.env
cp config/config.yaml data/hermes-home/config.yaml
cp proxy/caddy/Caddyfile.example proxy/caddy/Caddyfile
```

Then edit:

- `env/compose.env`
- `env/prod.env`
- `data/hermes-home/.env`

Set `HERMES_DOMAIN` in `env/prod.env` to the real DNS name that points at the server.

### 2. Start production stack

```bash
./scripts/up-prod.sh
```

The public entrypoint is Caddy on ports `80` and `443`. The Hermes containers remain internal to the Docker network.

### 3. Production logs

```bash
./scripts/logs-prod.sh
```

### 4. Stop production stack

```bash
./scripts/down-prod.sh
```

### 5. Firewall / DNS checklist

- Point the domain A/AAAA records at the server public IP.
- Allow inbound TCP `80` and `443`.
- Allow inbound UDP `443` only if you want HTTP/3.
- Keep direct Hermes ports closed publicly; Caddy is the intended ingress.

### 6. Notes

- Caddy persists certificate material in Docker volumes, so do not delete those volumes casually.
- If you expose Hermes beyond localhost, set a strong `API_SERVER_KEY` before enabling the API server.
- Real secrets, runtime state, and production domain files are intentionally excluded from Git.


## Backup and recovery

Hermes keeps durable state under `data/hermes-home/`. This is not disposable cache: it includes configuration, credentials, sessions, persistent memory, skills, cron data, and SQLite-backed history.

### What must be backed up

- `data/hermes-home/.env`
- `data/hermes-home/config.yaml`
- `data/hermes-home/memories/`
- `data/hermes-home/sessions/`
- `data/hermes-home/state.db`
- `data/hermes-home/skills/`
- `data/hermes-home/cron/`
- any additional provider-specific memory databases you enable later

### Create a backup

```bash
./scripts/backup.sh
```

This creates two artifacts under `backups/`:

1. an **official Hermes backup ZIP** created by `hermes backup`
2. a **raw directory tarball** for low-level inspection / last-resort recovery

By default, the scripts retain the newest **14** backups of each type. Override with:

```bash
BACKUP_RETENTION_COUNT=30 ./scripts/backup.sh
```

### Restore

```bash
./scripts/restore.sh /absolute/path/to/hermes-backup-YYYYMMDD-HHMMSS.zip
```

The restore flow stops the stack, imports the official Hermes backup, then starts the stack again.

### Recommended production schedule

Daily local backup example:

```cron
15 3 * * * cd /opt/yooooo-hermes-suite && BACKUP_RETENTION_COUNT=30 ./scripts/backup-prod.sh
```

For real disaster recovery, sync `backups/` off-host as well (object storage, another server, or encrypted remote backup). A same-disk backup does not protect against disk loss.

## Upgrade and health

### Local

```bash
./scripts/health.sh
./scripts/upgrade.sh
```

### Production

```bash
./scripts/health-prod.sh
./scripts/upgrade-prod.sh
```

The upgrade scripts create a backup first, pull newer images, recreate the stack, and run health checks afterward.

## Recovery notes

- Do **not** run two Hermes gateway containers against the same `data/hermes-home/` directory at once.
- SQLite data is part of the durable state. Prefer the official Hermes backup ZIP for restores instead of copying live SQLite sidecar files manually.
- If you later enable an external memory provider, verify its own persistence requirements too; some providers may add separate databases or external services beyond the built-in Hermes memory files.


## Off-host backups: Cloudflare R2 and Tencent Cloud COS

The repository supports off-host backup sync through Dockerized `rclone`, so the host does not need a native `rclone` install.

### 1. Prepare local-only files

```bash
cp env/remote-backup.env.example env/remote-backup.env
cp remote-backup/rclone.conf.example remote-backup/rclone.conf
```

Then edit both files with your real bucket names and credentials.

### 2. Supported remotes

- `r2` — Cloudflare R2
- `cos` — Tencent Cloud Object Storage

You may use one target or both at the same time:

```bash
REMOTE_BACKUP_TARGETS="r2:my-r2-bucket/hermes cos:my-cos-bucket/hermes"
```

### 3. Manual sync

```bash
./scripts/sync-backups.sh
```

### 4. Automatic sync after each backup

In `env/remote-backup.env`:

```bash
AUTO_REMOTE_BACKUP=true
```

Then every `backup.sh` / `backup-prod.sh` run will upload the new local backup set after creation.

### 5. Inspect remote backups

```bash
./scripts/list-remote-backups.sh
```

### 6. Restore from a remote object

```bash
./scripts/restore-from-remote.sh r2:my-r2-bucket/hermes/hermes-backup-YYYYMMDD-HHMMSS.zip
```

The script downloads the remote ZIP into `backups/restore-downloads/` and then uses the normal local restore flow.

### 7. Retention note

By default, remote sync uses `copy`, so removing old local backups does **not** delete remote backups. This is safer for disaster recovery. If you explicitly want the remote to mirror local retention, set:

```bash
REMOTE_BACKUP_SYNC_DELETE=true
```

Use that only if you are comfortable with remote deletions.
