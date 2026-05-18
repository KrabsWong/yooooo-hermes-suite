#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/env/remote-backup.env"
CONFIG_FILE="$ROOT_DIR/remote-backup/rclone.conf"

if [[ ! -f "$ENV_FILE" ]]; then
  printf 'Missing %s\n' "$ENV_FILE" >&2
  exit 1
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Missing %s\n' "$CONFIG_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$ENV_FILE"
: "${REMOTE_BACKUP_TARGETS:?REMOTE_BACKUP_TARGETS is required}"
: "${REMOTE_BACKUP_SYNC_DELETE:=false}"

for target in $REMOTE_BACKUP_TARGETS; do
  printf 'Syncing backups to %s ...\n' "$target"
  if [[ "$REMOTE_BACKUP_SYNC_DELETE" == "true" ]]; then
    docker run --rm \
      -v "$ROOT_DIR/backups:/data:ro" \
      -v "$CONFIG_FILE:/config/rclone/rclone.conf:ro" \
      rclone/rclone:latest sync /data "$target"
  else
    docker run --rm \
      -v "$ROOT_DIR/backups:/data:ro" \
      -v "$CONFIG_FILE:/config/rclone/rclone.conf:ro" \
      rclone/rclone:latest copy /data "$target"
  fi
done
