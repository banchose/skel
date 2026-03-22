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

tinfoil_start_proxy() {

  tinfoil proxy \
    -r tinfoilsh/confidential-model-router \
    -e inference.tinfoil.sh \
    -p 8080 >/dev/null 2>&1 &
}

# tf() {
#   local log_file
#   log_file="/tmp/tinfoil.$(date '+%s')"
#
#   if ! curl -s --connect-timeout 4 http://localhost:8080 >/dev/null 2>&1; then
#     tinfoil proxy \
#       -r tinfoilsh/confidential-model-router \
#       -e inference.tinfoil.sh \
#       -p 8080 \
#       >"${log_file}" 2>&1 &
#
#     local -i attempts=0
#     until curl -s --connect-timeout 1 http://localhost:8080 >/dev/null 2>&1; do
#       ((++attempts))
#       if ((attempts >= 10)); then
#         printf 'tinfoil proxy did not become ready (log: %s)\n' "${log_file}" >&2
#         return 1
#       fi
#       sleep 0.5
#     done
#   fi
#
#   command llm "$@" -t tin --ta
# }
