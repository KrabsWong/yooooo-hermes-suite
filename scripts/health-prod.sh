#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf '== Containers ==\n'
docker compose \
  --env-file "$ROOT_DIR/env/compose.env" \
  --env-file "$ROOT_DIR/env/prod.env" \
  -f "$ROOT_DIR/compose/docker-compose.yml" \
  -f "$ROOT_DIR/compose/docker-compose.prod.yml" \
  ps

printf '\n== Hermes config ==\n'
docker exec hermes-agent \
  /opt/hermes/.venv/bin/hermes config show | sed -n '1,30p'
