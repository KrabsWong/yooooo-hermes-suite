#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
mkdir -p "$ROOT_DIR/backups"
tar -C "$ROOT_DIR/data" -czf "$ROOT_DIR/backups/hermes-home-$STAMP.tar.gz" hermes-home
printf 'Created %s\n' "$ROOT_DIR/backups/hermes-home-$STAMP.tar.gz"
