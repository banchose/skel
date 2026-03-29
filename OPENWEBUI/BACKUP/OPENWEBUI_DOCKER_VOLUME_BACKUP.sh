#!/usr/bin/env bash

set -euo pipefail

COMPOSE_DIR="/apps/OpenWebUI"
BACKUP_DIR="/apps/BACKUP"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

cleanup() {
  # Always bring the stack back up, even if backup fails
  cd "${COMPOSE_DIR}" && docker compose up -d
}
trap cleanup EXIT

VOLUME_PATH=$(docker volume inspect openwebui_open-webui --format '{{ .Mountpoint }}')

# Validate before we take anything down
[[ -d "${VOLUME_PATH}" ]] || {
  printf >&2 'Volume path not found: %s\n' "${VOLUME_PATH}"
  exit 1
}
mkdir -p "${BACKUP_DIR}"

cd "${COMPOSE_DIR}"

# 1. Cold backup: stop the stack
docker compose down

# 2. Tar the volume
tar -czf "${BACKUP_DIR}/open-webui-${TIMESTAMP}.tar.gz" \
  -C "$(dirname "${VOLUME_PATH}")" \
  "$(basename "${VOLUME_PATH}")"

# 3. Stack comes back up via the EXIT trap — but bring it up explicitly here
#    so the prune/rclone steps run with the service already restored.
cd "${COMPOSE_DIR}" && docker compose up -d
trap - EXIT # Disarm now that we're back up

# 4. Prune backups older than 30 days
find "${BACKUP_DIR}" -name "open-webui-*.tar.gz" -type f -mtime +30 -delete

# 5. Push offsite (optional)
# rclone copy "${BACKUP_DIR}/open-webui-${TIMESTAMP}.tar.gz" remote:bucket/openwebui/
