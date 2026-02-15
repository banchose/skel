#!/usr/bin/env bash

set -exuo pipefail

curl -X POST https://inference.tinfoil.sh/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
  -d '{
    "model": "kimi-k2-5",
    "messages": [
      {
        "role": "user",
        "content": "Hello!"
      }
    ]
  }'
