#!/usr/bin/env bash
# Waybar reachability check: ping_host.sh <ip> <label>
# Prints "UP<label>" / "DN<label>" with class UP / DOWN.
set -uo pipefail

host="${1:?usage: ${0##*/} <ip> <label>}"
label="${2:?usage: ${0##*/} <ip> <label>}"

if ping -nq -c 1 -W 3 "${host}" >/dev/null 2>&1; then
  printf '{"text":"UP%s","alt":"UP","class":"UP","tooltip":"%s reachable"}\n' "${label}" "${host}"
else
  printf '{"text":"DN%s","alt":"DOWN","class":"DOWN","tooltip":"%s unreachable"}\n' "${label}" "${host}"
fi
