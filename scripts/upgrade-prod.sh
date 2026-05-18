#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf 'Creating pre-upgrade backup...\n'
"$ROOT_DIR/scripts/backup-prod.sh"

printf '\nPulling latest images...\n'
docker compose \
  --env-file "$ROOT_DIR/env/compose.env" \
  --env-file "$ROOT_DIR/env/prod.env" \
  -f "$ROOT_DIR/compose/docker-compose.yml" \
  -f "$ROOT_DIR/compose/docker-compose.prod.yml" \
  pull

printf '\nRecreating production stack...\n'
"$ROOT_DIR/scripts/up-prod.sh"

printf '\nRunning production health check...\n'
"$ROOT_DIR/scripts/health-prod.sh"
