#!/usr/bin/env bash

set -xeuo pipefail

[[ -z ${OPENROUTER_API_KEY:-} ]] && {
  echo "\$OPENROUTER_API_KEY not set"
  exit 1
}

curl https://openrouter.ai/api/v1/chat/completions \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
  "preset": "@preset/bash-skill",
  "model": "anthropic/claude-sonnet-4-6",
  "messages": [
      {
          "role": "user",
          "content": "This is a test message. Respond with 'OK'"
      }
  ]
}'
