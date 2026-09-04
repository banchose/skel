#!/usr/bin/env bash
# Wolfram|Alpha LLM API. Usage: wolfram-alpha.sh "query" [maxchars] [extra curl -d params...]
#   wolfram-alpha.sh "density of gold"
#   wolfram-alpha.sh "pi" 500
#   wolfram-alpha.sh "mercury" 6800 assumption='*C.mercury-_*Planet-'
set -euo pipefail
: "${WOLFRAM_APP_ID:?set WOLFRAM_APP_ID (https://developer.wolframalpha.com/)}"
[[ $# -ge 1 ]] || { echo "usage: $0 'query' [maxchars] [param=value...]" >&2; exit 2; }
q=$1; max=${2:-6800}; shift; [[ $# -gt 0 ]] && shift
extra=(); for p in "$@"; do extra+=(--data-urlencode "$p"); done

# --fail-with-body (7.76+) keeps the 501 "Things to try instead" suggestions on stderr
curl -sS -G --fail-with-body https://www.wolframalpha.com/api/v1/llm-api \
  -H "Authorization: Bearer $WOLFRAM_APP_ID" \
  --data-urlencode "input=$q" --data-urlencode "maxchars=$max" "${extra[@]}" \
  && echo \
  || { echo; echo "(501 = Wolfram could not interpret input; 401/403 = bad AppID)" >&2; exit 1; }
