#!/usr/bin/env bash
set -euo pipefail

readonly URL="https://query1.finance.yahoo.com/v8/finance/chart/CL=F?range=1d&interval=1d"
readonly CACHE_FILE="${XDG_RUNTIME_DIR:-/tmp}/oil_price_cache.json"

# WTI crude futures (NYMEX/Globex) trade Sun 18:00 ET → Fri 17:00 ET
# with a daily halt 17:00–18:00 ET each weekday.
is_market_open() {
  local dow hour min
  dow=$(date +%u) # 1=Mon .. 7=Sun
  hour=$(date +%-H)
  min=$(date +%-M)
  local now_min=$((hour * 60 + min))

  # Saturday all day: closed
  if ((dow == 6)); then
    return 1
  fi

  # Sunday before 18:00 ET: closed
  if ((dow == 7 && now_min < 1080)); then
    return 1
  fi

  # Friday after 17:00 ET: closed
  if ((dow == 5 && now_min >= 1020)); then
    return 1
  fi

  # Weekday daily halt 17:00–18:00 ET
  if ((now_min >= 1020 && now_min < 1080)); then
    return 1
  fi

  return 0
}

serve_cache() {
  if [[ -f "${CACHE_FILE}" ]]; then
    cat "${CACHE_FILE}"
  else
    printf '{"text":"🛢️ --","tooltip":"Oil: market closed, no cache","class":"stale"}\n'
  fi
}

if ! is_market_open; then
  serve_cache
  exit 0
fi

data=$(curl -sf --max-time 10 "${URL}" 2>/dev/null) || {
  serve_cache
  exit 0
}

if [[ -z "${data}" ]]; then
  serve_cache
  exit 0
fi

read -r price prev high low < <(
  printf '%s' "${data}" | jq -r '
        .chart.result[0].meta |
        [.regularMarketPrice, .chartPreviousClose, .regularMarketDayHigh, .regularMarketDayLow]
        | @tsv
    '
) || {
  serve_cache
  exit 0
}

change=$(awk -v p="${price}" -v c="${prev}" 'BEGIN { printf "%.2f", p - c }')
pct=$(awk -v p="${price}" -v c="${prev}" 'BEGIN { printf "%.2f", ((p - c) / c) * 100 }')

if (($(awk -v ch="${change}" 'BEGIN { print (ch >= 0) }'))); then
  arrow="▲"
  class="oil-up"
else
  arrow="▼"
  class="oil-down"
fi

tooltip="WTI Crude (CL=F)\\nPrice: \$${price}\\nChange: ${change} (${pct}%)\\nHigh: \$${high}\\nLow: \$${low}\\nPrev Close: \$${prev}"

output=$(printf '{"text":"🛢️ $%s %s%s%%","tooltip":"%s","class":"%s"}\n' \
  "${price}" "${arrow}" "${pct}" "${tooltip}" "${class}")

printf '%s' "${output}" >"${CACHE_FILE}"
printf '%s\n' "${output}"
