# Disaster Recovery Guide

This guide is for recovering **Yooooo Hermes Suite** after host loss, disk corruption, or accidental deletion.

## What matters most

Hermes durable state lives under:

```text
data/hermes-home/
```

Treat this as non-disposable data. It contains:

- secrets and provider credentials
- model configuration
- sessions
- persistent memories
- skills
- cron state
- SQLite-backed state such as `state.db`

A fresh clone of the repository is **not** enough to recover your Hermes history. You also need a backup of Hermes state.

## Preferred recovery source

Prefer the official Hermes backup ZIP produced by:

```bash
./scripts/backup.sh
# or
./scripts/backup-prod.sh
```

The raw tarball is useful for inspection and last-resort manual recovery, but the official ZIP is the normal restore path.

## Before an incident happens

Recommended production posture:

1. Run scheduled backups daily.
2. Sync backups off-host to Cloudflare R2, Tencent COS, or both.
3. Keep remote deletion disabled unless you intentionally want mirroring.
4. Periodically test a restore on a non-production machine.

Example cron:

```cron
15 3 * * * cd /opt/yooooo-hermes-suite && BACKUP_RETENTION_COUNT=30 ./scripts/backup-prod.sh
```

## Recovery path A: you still have a local backup ZIP

1. Recreate the server and install Docker.
2. Clone the repository.
3. Recreate local-only env files from the examples.
4. Place the backup ZIP somewhere accessible on disk.
5. Run:

```bash
./scripts/restore-prod.sh /absolute/path/to/hermes-backup-YYYYMMDD-HHMMSS.zip
```

6. Validate:

```bash
./scripts/health-prod.sh
```

7. Confirm in the UI that recent sessions and memories are present.

## Recovery path B: local disk is gone, restore from R2 or COS

1. Recreate the server and install Docker.
2. Clone the repository.
3. Recreate:

```bash
cp env/compose.env.example env/compose.env
cp env/hermes.env.example data/hermes-home/.env
cp env/prod.env.example env/prod.env
cp config/config.yaml data/hermes-home/config.yaml
cp proxy/caddy/Caddyfile.example proxy/caddy/Caddyfile
cp env/remote-backup.env.example env/remote-backup.env
cp remote-backup/rclone.conf.example remote-backup/rclone.conf
```

4. Fill in the real values for:

- `env/compose.env`
- `env/prod.env`
- `data/hermes-home/.env`
- `remote-backup/rclone.conf`

5. List remote backups:

```bash
./scripts/list-remote-backups.sh
```

6. Restore the desired ZIP:

```bash
./scripts/restore-from-remote.sh r2:bucket/path/hermes-backup-YYYYMMDD-HHMMSS.zip
# or
./scripts/restore-from-remote.sh cos:bucket/path/hermes-backup-YYYYMMDD-HHMMSS.zip
```

7. Validate:

```bash
./scripts/health-prod.sh
```

## Post-restore validation checklist

After any recovery, confirm:

- WebUI loads
- Hermes responds to a test prompt
- expected sessions are visible
- expected memories are present
- backup jobs still run
- off-host sync still works
- DNS / HTTPS still point to the recovered host

## Important safety notes

- Do not run two active Hermes gateway containers against the same `data/hermes-home/` directory.
- Do not rely only on same-disk backups.
- Do not manually copy live SQLite sidecar files as your primary recovery method if an official Hermes backup ZIP is available.
- If you later enable external memory services, document and back up those dependencies separately too.
