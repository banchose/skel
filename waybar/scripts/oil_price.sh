#!/usr/bin/env bash
set -euo pipefail

readonly URL="https://query1.finance.yahoo.com/v8/finance/chart/CL=F?range=1d&interval=1d"

data=$(curl -sf --max-time 10 "${URL}" 2>/dev/null) || {
  printf '{"text":"🛢️ --","tooltip":"Oil: fetch failed","class":"stale"}\n'
  exit 0
}

if [[ -z "${data}" ]]; then
  printf '{"text":"🛢️ --","tooltip":"Oil: no data","class":"stale"}\n'
  exit 0
fi

read -r price prev high low < <(
  printf '%s' "${data}" | jq -r '
        .chart.result[0].meta |
        [.regularMarketPrice, .chartPreviousClose, .regularMarketDayHigh, .regularMarketDayLow]
        | @tsv
    '
) || {
  printf '{"text":"🛢️ --","tooltip":"Oil: parse error","class":"stale"}\n'
  exit 0
}

change=$(awk "BEGIN { printf \"%.2f\", ${price} - ${prev} }")
pct=$(awk "BEGIN { printf \"%.2f\", ((${price} - ${prev}) / ${prev}) * 100 }")

if (($(awk "BEGIN { print (${change} >= 0) }"))); then
  arrow="▲"
  class="oil-up"
else
  arrow="▼"
  class="oil-down"
fi

tooltip="WTI Crude (CL=F)\\nPrice: \$${price}\\nChange: ${change} (${pct}%)\\nHigh: \$${high}\\nLow: \$${low}\\nPrev Close: \$${prev}"

printf '{"text":"🛢️ $%s %s%s%%","tooltip":"%s","class":"%s"}\n' \
  "${price}" "${arrow}" "${pct}" "${tooltip}" "${class}"
