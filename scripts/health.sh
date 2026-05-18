#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf '== Containers ==\n'
docker compose \
  --env-file "$ROOT_DIR/env/compose.env" \
  -f "$ROOT_DIR/compose/docker-compose.yml" \
  -f "$ROOT_DIR/compose/docker-compose.local.yml" \
  ps

printf '\n== WebUI ==\n'
for _ in {1..20}; do
  if curl -fsS http://127.0.0.1:8787/ >/dev/null; then
    printf 'WebUI reachable on http://127.0.0.1:8787\n'
    break
  fi
  sleep 2
done
curl -fsS http://127.0.0.1:8787/ >/dev/null

printf '\n== Hermes config ==\n'
docker exec hermes-agent \
  /opt/hermes/.venv/bin/hermes config show | sed -n '1,30p'
