#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$ROOT_DIR/backups"
RETENTION_COUNT="${BACKUP_RETENTION_COUNT:-14}"
STAMP="$(date +%Y%m%d-%H%M%S)"
ZIP_PATH="$BACKUP_DIR/hermes-backup-$STAMP.zip"
RAW_PATH="$BACKUP_DIR/hermes-home-raw-$STAMP.tar.gz"

mkdir -p "$BACKUP_DIR"

docker exec hermes-agent \
  /opt/hermes/.venv/bin/hermes backup \
  --output "/tmp/hermes-backup-$STAMP.zip"

docker cp "hermes-agent:/tmp/hermes-backup-$STAMP.zip" "$ZIP_PATH"
docker exec hermes-agent rm -f "/tmp/hermes-backup-$STAMP.zip"

tar -C "$ROOT_DIR/data" -czf "$RAW_PATH" hermes-home

count=0
for file in $(ls -1t "$BACKUP_DIR"/hermes-backup-*.zip 2>/dev/null || true); do
  count=$((count + 1))
  if [[ "$count" -gt "$RETENTION_COUNT" ]]; then
    rm -f "$file"
  fi
done

count=0
for file in $(ls -1t "$BACKUP_DIR"/hermes-home-raw-*.tar.gz 2>/dev/null || true); do
  count=$((count + 1))
  if [[ "$count" -gt "$RETENTION_COUNT" ]]; then
    rm -f "$file"
  fi
done

printf 'Created official backup: %s\n' "$ZIP_PATH"
printf 'Created raw archive:     %s\n' "$RAW_PATH"
printf 'Retention count:        %s per backup type\n' "$RETENTION_COUNT"
