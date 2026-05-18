# Yooooo Hermes Suite

A Docker-based deployment repository for running **Hermes Agent** and **Hermes WebUI** together while keeping host dependencies minimal.

## Layout

- `compose/` — Docker Compose stack definition
- `env/` — tracked examples plus local compose settings
- `config/` — tracked Hermes config template
- `data/hermes-home/` — local runtime state, secrets, sessions, logs, and databases (**gitignored**)
- `scripts/` — convenience commands for lifecycle and backup

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
