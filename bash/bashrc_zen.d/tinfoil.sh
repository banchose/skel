#!/usr/bin/env bash

## Tinfoil Models
# deepseek-r1-0528
# kimi-k2-5
# gpt-oss-120b
# llama3-3-70b

tinllm() {
  curl -sS https://inference.tinfoil.sh/v1/chat/completions -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "model": "kimi-k2-5",
  "messages": [{"role": "user", "content": "Hello, world!"}],
  "temperature": 0
}'
}

tinfoil_get_docs_md() {
  curl -s https://docs.tinfoil.sh/llms-full.txt -o tinfoil-docs-full.md
}

tinfoil-transcribe() {
  curl -s http://127.0.0.1:8080/v1/audio/transcriptions \
    -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -F file=@"$1" \
    -F model=whisper-large-v3-turbo | jq -r '.text'
}
