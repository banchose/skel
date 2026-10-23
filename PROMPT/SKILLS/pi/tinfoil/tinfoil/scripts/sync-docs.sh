#!/usr/bin/env bash
# Re-download the subset of docs.tinfoil.sh pages cached under references/docs/.
# Pages are the markdown versions (append .md to the docs path). Add/remove paths below.
set -euo pipefail
dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../references/docs" && pwd)"
pages=(
  introduction quickstart get-api-key resources/feature-status
  models/overview models/chat models/vision
  sdk/overview sdk/javascript-sdk sdk/cli-sdk sdk/direct-api-access sdk/prompt-caching sdk/error-handling
  guides/reasoning guides/proxy-server local-proxy/cli
  verification/verification-in-tinfoil verification/attestation-architecture resources/ehbp
)
rc=0
for p in "${pages[@]}"; do
  out="$dir/${p//\//__}.md"; tmp="$out.tmp"
  code=$(curl -sS -m 30 -o "$tmp" -w '%{http_code}' "https://docs.tinfoil.sh/$p.md") || code=ERR
  if [[ "$code" == 200 ]]; then mv "$tmp" "$out"; printf '%-45s %6s bytes\n' "$p" "$(wc -c <"$out")"
  else echo "FAIL $p ($code)" >&2; rm -f "$tmp"; rc=1; fi
done
date -u +%Y-%m-%d > "$dir/.synced"
exit $rc
