#!/usr/bin/env bash

set -ueo pipefail

curl -s https://openrouter.ai/api/v1/chat/completions -H "Authorization: Bearer ${OPENROUTER_API_KEY}" -H "Content-Type: application/json" -d '{
    "model": "anthropic/claude-sonnet-4-6,
    "messages": [
      {
        "role": "user",
        "content": "This is just a test to see if this is working. Please respond with 'OK'"
      }
    ]
  }' | jq '.'
