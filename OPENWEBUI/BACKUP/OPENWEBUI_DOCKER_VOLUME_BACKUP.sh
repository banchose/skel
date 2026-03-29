#!/usr/bin/env bash
set -euo pipefail

COMPOSE_DIR="/apps/OpenWebUI"
BACKUP_DIR="/apps/BACKUP"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
VOLUME_NAME="openwebui_open-webui"
KEEP=5

export AWS_BEARER_TOKEN_BEDROCK="${AWS_BEARER_TOKEN_BEDROCK:-}"

cleanup() {
  cd "${COMPOSE_DIR}" && docker compose up -d
}
trap cleanup EXIT

mkdir -p "${BACKUP_DIR}"

cd "${COMPOSE_DIR}"
docker compose down

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "${VOLUME_NAME}":/source:ro \
  -v "${BACKUP_DIR}":/backup \
  alpine tar -czf "/backup/open-webui-${TIMESTAMP}.tar.gz" -C /source .

cd "${COMPOSE_DIR}" && docker compose up -d
trap - EXIT

# Prune: keep only the newest $KEEP backups
readarray -t backups < <(
  find "${BACKUP_DIR}" -maxdepth 1 -name 'open-webui-*.tar.gz' -type f -printf '%T@ %p\n' |
    sort -rn |
    tail -n +$((KEEP + 1)) |
    cut -d' ' -f2-
)

for f in "${backups[@]}"; do
  [[ -n "${f}" ]] && rm -f "${f}"
done
