#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$ROOT_DIR/remote-backup/rclone.conf"
REMOTE_PATH="${1:-}"

if [[ -z "$REMOTE_PATH" ]]; then
  printf 'Usage: %s remote:path/to/hermes-backup.zip\n' "$0" >&2
  exit 1
fi
if [[ ! -f "$CONFIG_FILE" ]]; then
  printf 'Missing %s\n' "$CONFIG_FILE" >&2
  exit 1
fi

mkdir -p "$ROOT_DIR/backups/restore-downloads"
BASENAME="$(basename "$REMOTE_PATH")"
LOCAL_PATH="$ROOT_DIR/backups/restore-downloads/$BASENAME"

docker run --rm \
  -v "$ROOT_DIR/backups/restore-downloads:/data" \
  -v "$CONFIG_FILE:/config/rclone/rclone.conf:ro" \
  rclone/rclone:latest copyto "$REMOTE_PATH" "/data/$BASENAME"

"$ROOT_DIR/scripts/restore.sh" "$LOCAL_PATH"
