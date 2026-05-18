#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf 'Creating pre-upgrade backup...\n'
"$ROOT_DIR/scripts/backup.sh"

printf '\nPulling latest images...\n'
docker compose \
  --env-file "$ROOT_DIR/env/compose.env" \
  -f "$ROOT_DIR/compose/docker-compose.yml" \
  -f "$ROOT_DIR/compose/docker-compose.local.yml" \
  pull

printf '\nRecreating local stack...\n'
"$ROOT_DIR/scripts/up.sh"

printf '\nRunning health check...\n'
"$ROOT_DIR/scripts/health.sh"
