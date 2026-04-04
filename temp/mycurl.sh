#!/usr/bin/env bash
set -xeuo pipefail

curl -X POST https://api.anthropic.com/v1/messages \
  -H "anthropic-version: 2023-06-01" \
  -H "X-Api-Key: ${ANTHROPIC_API_KEY}" \
  -H "Content Type: application/json" \
  -d '{
      "model": "claude-sonnet-4-6",
      "max_tokens": 1024,
      "messages": [
        {
          "content": "This is a test. Generate a brief response",
          "role": "user"
        }
      ]
}'
