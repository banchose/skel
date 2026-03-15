#!/usr/bin/env bash

set -exuo pipefail

## Tinfoil Models
# deepseek-r1-0528
# kimi-k2-5
# gpt-oss-120b
# llama3-3-70b

curl -sS https://inference.tinfoil.sh/v1/chat/completions -H "Authorization: Bearer ${TINFOIL_API_KEY}" -H "Content-Type: application/json" -d '{
  "model": "kimi-k2-5",
  "messages": [{"role": "user", "content": "Hello, world!"}],
  "temperature": 0
}'
