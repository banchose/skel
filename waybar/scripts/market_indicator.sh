#!/usr/bin/env bash
set -euo pipefail

# Usage: market_indicator.sh <SYMBOL> <ICON> <LABEL> <ID> [invert] [fmt]
#
#   SYMBOL  — Yahoo Finance symbol (e.g. CL=F, GC=F, ^VIX, ^TNX)
#   ICON    — Emoji for display (e.g. 🛢️, 🪙, 😰, 📈)
#   LABEL   — Human-readable name for tooltip (e.g. "WTI Crude")
#   ID      — Short id for cache file and CSS class (e.g. oil, gold, vix, tnx)
#   invert  — Optional: "invert" to flip up/down color semantics (VIX: up=bad)
#   fmt     — Optional: "dollar" (default), "index", "pct"
#
# Examples:
#   market_indicator.sh "CL=F"  "🛢️" "WTI Crude"   oil
#   market_indicator.sh "GC=F"  "🪙"  "Gold"         gold
#   market_indicator.sh "^VIX"  "😰"  "VIX"          vix    invert index
#   market_indicator.sh "^TNX"  "📈"  "10Y Yield"    tnx    ""     pct

readonly SYMBOL="${1:?Usage: $0 SYMBOL ICON LABEL ID [invert] [fmt]}"
readonly ICON="${2:?}"
readonly LABEL="${3:?}"
readonly ID="${4:?}"
readonly INVERT="${5:-}"
readonly FMT="${6:-dollar}"

# URL-encode carets for symbols like ^VIX, ^TNX
readonly ENCODED_SYMBOL="${SYMBOL//^/%5E}"
readonly URL="https://query1.finance.yahoo.com/v8/finance/chart/${ENCODED_SYMBOL}?range=1d&interval=1d"
readonly CACHE_FILE="${XDG_RUNTIME_DIR:-/tmp}/market_${ID}_cache.json"

# Simple weekend check — skip fetching Sat/Sun to avoid pointless requests.
# No per-market hours logic; Yahoo returns last known price anyway and
# the cache handles staleness gracefully.
is_weekend() {
  local dow
  dow=$(date '+%u')
  ((dow == 6 || dow == 7))
}

serve_cache() {
  if [[ -f "${CACHE_FILE}" ]]; then
    cat "${CACHE_FILE}"
  else
    printf '{"text":"%s --","tooltip":"%s: no data cached","class":"stale"}\n' \
      "${ICON}" "${LABEL}"
  fi
}

if is_weekend; then
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

# Determine direction — "invert" flips the color meaning (VIX up = bad = red)
is_positive=$(awk -v ch="${change}" 'BEGIN { print (ch >= 0) }')

if [[ "${INVERT}" == "invert" ]]; then
  if ((is_positive)); then
    arrow="▲"
    class="${ID}-up-bad"
  else
    arrow="▼"
    class="${ID}-down-good"
  fi
else
  if ((is_positive)); then
    arrow="▲"
    class="${ID}-up"
  else
    arrow="▼"
    class="${ID}-down"
  fi
fi

# Format the price display based on instrument type
case "${FMT}" in
dollar)
  display_price=$(printf '$%s' "${price}")
  tip_price=$(printf '$%s' "${price}")
  tip_high=$(printf '$%s' "${high}")
  tip_low=$(printf '$%s' "${low}")
  tip_prev=$(printf '$%s' "${prev}")
  ;;
pct)
  display_price=$(printf '%s%%' "${price}")
  tip_price=$(printf '%s%%' "${price}")
  tip_high=$(printf '%s%%' "${high}")
  tip_low=$(printf '%s%%' "${low}")
  tip_prev=$(printf '%s%%' "${prev}")
  ;;
index | *)
  display_price="${price}"
  tip_price="${price}"
  tip_high="${high}"
  tip_low="${low}"
  tip_prev="${prev}"
  ;;
esac

tooltip="${LABEL} (${SYMBOL})\\nPrice: ${tip_price}\\nChange: ${change} (${pct}%)\\nHigh: ${tip_high}\\nLow: ${tip_low}\\nPrev Close: ${tip_prev}"

output=$(printf '{"text":"%s %s %s%s%%","tooltip":"%s","class":"%s"}\n' \
  "${ICON}" "${display_price}" "${arrow}" "${pct}" "${tooltip}" "${class}")

printf '%s' "${output}" >"${CACHE_FILE}"
printf '%s\n' "${output}"
