#!/usr/bin/env bash

set -euo pipefail

# ── Constants ────────────────────────────────────────────────────────────────
readonly AWS_PROFILE="test"
readonly AWS_REGION="us-east-1"
readonly LITELLM_PORT=4000
readonly LITELLM_CONF="${HOME}/gitdir/skel/llm/litellm/litellm.conf"

# ── Functions ────────────────────────────────────────────────────────────────
die() {
  printf '%s\n' "$*" >&2
  exit 1
}

ensure_aws_session() {
  printf 'Checking AWS session...\n'
  if ! aws sts get-caller-identity \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" &>/dev/null; then
    printf 'No active session. Initiating SSO login...\n'
    aws sso login --no-browser --use-device-code --profile "${AWS_PROFILE}" ||
      die "SSO login failed"
  fi
  aws sts get-caller-identity \
    --region "${AWS_REGION}" \
    --profile "${AWS_PROFILE}" ||
    die "Unable to verify AWS identity"
}

write_litellm_config() {
  mkdir -p "$(dirname "${LITELLM_CONF}")"
  cat >"${LITELLM_CONF}" <<EOF
model_list:
  - model_name: bedrock-sonnet
    litellm_params:
      model: bedrock/us.anthropic.claude-sonnet-4-6
      aws_region_name: ${AWS_REGION}
      aws_profile_name: ${AWS_PROFILE}
EOF
  printf 'LiteLLM config written to %s\n' "${LITELLM_CONF}"
}

write_extra_models() {
  local llm_config_dir extra_models
  command -v llm >/dev/null 2>&1 || die "'llm' not found in PATH"

  llm_config_dir="$(dirname "$(llm logs path)")"
  extra_models="${llm_config_dir}/extra-openai-models.yaml"

  cat >"${extra_models}" <<EOF
- model_id: brs
  model_name: bedrock-sonnet
  api_base: "http://localhost:${LITELLM_PORT}"
  aliases: ["bedrock-proxy"]
  supports_tools: true
EOF
  printf 'extra-openai-models.yaml written to %s\n' "${extra_models}"
}

start_proxy() {
  command -v litellm >/dev/null 2>&1 || die "'litellm' not found in PATH"
  printf 'Starting LiteLLM proxy on port %d...\n' "${LITELLM_PORT}"
  printf 'Run this in a dedicated tmux pane, or press Ctrl-C to skip and start manually.\n'
  litellm --config "${LITELLM_CONF}" --port "${LITELLM_PORT}"
}

# ── Main ─────────────────────────────────────────────────────────────────────
main() {
  ensure_aws_session
  write_litellm_config
  write_extra_models
  start_proxy
}

main "$@"
