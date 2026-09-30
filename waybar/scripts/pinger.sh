#!/usr/bin/env bash
# Waybar custom/pinger: round-trip latency (ms) to a public host.
# Emits class UP / WARN / CRIT / DOWN for CSS colouring; "alt" mirrors class
# so format-icons can key on it.
set -uo pipefail

host="${1:-1.1.1.1}"

# cut -s: only lines containing the delimiter (the rtt min/avg/max/mdev line)
rtt=$(ping -nq -c 1 -W 1 "${host}" | cut -s -d/ -f5)
ms=${rtt%.*}

if [[ -z ${ms} ]]; then
  ms=0 class=DOWN
elif (( ms < 30 )); then
  class=UP
elif (( ms < 100 )); then
  class=WARN
else
  class=CRIT
fi

printf '{"text":"%s","alt":"%s","class":"%s","tooltip":"ping %s: %s ms"}\n' \
  "${ms}" "${class}" "${class}" "${host}" "${ms}"
