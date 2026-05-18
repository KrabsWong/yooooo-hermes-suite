#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_FILE="${1:-}"

if [[ -z "$BACKUP_FILE" ]]; then
  printf 'Usage: %s /absolute/path/to/hermes-backup.zip\n' "$0" >&2
  exit 1
fi
if [[ ! -f "$BACKUP_FILE" ]]; then
  printf 'Backup file not found: %s\n' "$BACKUP_FILE" >&2
  exit 1
fi

"$ROOT_DIR/scripts/down-prod.sh"

docker compose   --env-file "$ROOT_DIR/env/compose.env"   --env-file "$ROOT_DIR/env/prod.env"   -f "$ROOT_DIR/compose/docker-compose.yml"   -f "$ROOT_DIR/compose/docker-compose.prod.yml"   up -d hermes-agent

docker cp "$BACKUP_FILE" "hermes-agent:/tmp/hermes-restore.zip"
docker exec hermes-agent   /opt/hermes/.venv/bin/hermes import --force /tmp/hermes-restore.zip
docker exec hermes-agent rm -f /tmp/hermes-restore.zip

"$ROOT_DIR/scripts/up-prod.sh"
printf 'Production restore completed from %s\n' "$BACKUP_FILE"
