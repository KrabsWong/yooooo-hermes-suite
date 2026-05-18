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

for target in $REMOTE_BACKUP_TARGETS; do
  printf '== %s ==\n' "$target"
  docker run --rm \
    -v "$CONFIG_FILE:/config/rclone/rclone.conf:ro" \
    rclone/rclone:latest lsl "$target"
  printf '\n'
done
