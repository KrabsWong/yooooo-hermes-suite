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
