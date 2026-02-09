#!/usr/bin/env bash

set -xeuo pipefail

MODEL=anthropic/claude-sonnet-4.5

[[ -v OPENROUTER_API_KEY ]] || {
  echo "OPENROUTER_API_KEY not set"
  exit 1
}

curl https://openrouter.ai/api/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENROUTER_API_KEY" \
  -d '{
  "model": "'"${MODEL}"'",
  "messages": [
    {
      "role": "user",
      "content": "This is just a test.  Please only reply with a short acknoledgement"
    }
  ]
}'
