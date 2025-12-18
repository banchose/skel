#!/usr/bin/env bash
set -xeuo pipefail

# TLS certificate deployment script for porkbun-provided Let's Encrypt certs
# Usage: Download bundle from Porkbun, then run this script

readonly BUNDLEZIP="xaax.dev-ssl-bundle.zip"
readonly CERTDEST="/apps/traefik/etc/certs" # Change as needed
# readonly CERTDEST="/tmp"
readonly DOWNLOAD_DIR="${HOME}/Downloads"

# Cleanup on exit
trap 'rm -rf "${DOWNLOAD_DIR}/${BUNDLEZIP%.*}"' EXIT

cd "${DOWNLOAD_DIR}"

# Verify bundle exists
[[ -r ./${BUNDLEZIP} ]] || {
  echo "Error: ${BUNDLEZIP} not found in ${DOWNLOAD_DIR}" >&2
  exit 1
}

# Extract bundle
unzip -q -- ./"${BUNDLEZIP}" || {
  echo "Error: Failed to unzip ${BUNDLEZIP}" >&2
  exit 1
}

cd "${BUNDLEZIP%.*}"

# Verify .pem files exist
shopt -s nullglob
pem_files=(*.pem)
[[ ${#pem_files[@]} -gt 0 ]] || {
  echo "Error: No .pem files found in bundle" >&2
  exit 1
}

# Deploy to remote (atomically set permissions)
scp -- *.pem star:"${CERTDEST}/" &&
  ssh star "cd ${CERTDEST} && \
    chmod 400 *.pem && \
    cp domain.cert.pem cert.pem && \
    cp private.key.pem key.pem"
