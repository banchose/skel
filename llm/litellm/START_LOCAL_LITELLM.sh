#!/usr/bin/env bash
set -euo pipefail

LITELLM_CONFIG_DIR="$HOME/gitdir/skel/llm/litellm"
LITELLM_CONFIG="litellm.conf"
LITELLM_PORT=4000
AWS_PROFILE_NAME="test"

echo "=== Starting LiteLLM Bedrock Proxy ==="

# Check litellm exists
command -v litellm >/dev/null 2>&1 || {
  echo "ERROR: litellm not found."
  echo "FIX:   pipx install 'litellm[proxy]'"
  exit 1
}

# Check AWS auth is active
if ! aws sts get-caller-identity --profile "${AWS_PROFILE_NAME}" >/dev/null 2>&1; then
  echo "ERROR: AWS session not active for profile '${AWS_PROFILE_NAME}'."
  echo "FIX:   aws sso login --profile ${AWS_PROFILE_NAME}"
  exit 1
fi
echo "OK: AWS profile '${AWS_PROFILE_NAME}' authenticated."

# Check port not already in use
if ss -tlnp 2>/dev/null | grep -q ":${LITELLM_PORT} "; then
  echo "WARNING: Port ${LITELLM_PORT} already in use. LiteLLM may already be running."
  echo "         Check with: curl -s http://localhost:${LITELLM_PORT}/health"
  exit 1
fi

# Check config exists
if [[ ! -f "${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}" ]]; then
  echo "ERROR: Config not found: ${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}"
  exit 1
fi

echo "Starting proxy on port ${LITELLM_PORT}..."
echo "Stop with Ctrl+C"
echo ""

set -x
litellm -c "${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}" --port "${LITELLM_PORT}"
