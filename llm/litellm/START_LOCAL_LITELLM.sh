#!/usr/bin/env bash

set -xeuo pipefail

LITELLM_CONFIG_DIR=$HOME/gitdir/skel/llm/litellm
LITELLM_CONFIG=litellm.conf
LITELLM_PORT=4000

command -v litellm 2>&1 || {
  echo "litellm mising... try pipx install litellm['proxy']"
  exit 1
}

litellm -c "${LITELLM_CONFIG_DIR}/${LITELLM_CONFIG}" --port "${LITELLM_PORT}"
