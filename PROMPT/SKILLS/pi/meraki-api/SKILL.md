---
name: meraki
description: Read Cisco Meraki Dashboard API v1 data with curl — org/network/device discovery and MX firewall rules (L3, L7, inbound, cellular, port forwarding, 1:1 and 1:many NAT, site-to-site VPN firewall). Read-only GETs, jq formatting, rate-limit and pagination handling. Use when asked to inspect, audit, list, or compare Meraki firewall rules, networks, devices, or uplink addresses.
---

# Meraki Dashboard API v1 via curl

**Read-only skill. GET only.** Never issue PUT/POST/DELETE against Meraki — those change
production network config. If a task needs a write, stop and report what would change.

## Setup

```sh
export MERAKI_API_KEY=...          # never echo, never paste into a command line as a literal
B=https://api.meraki.com/api/v1    # .ca / .cn / .in / api.gov-meraki.com for those dashboards
H="Authorization: Bearer $MERAKI_API_KEY"
```

Always pass `-L`: the API 302-redirects to your org's shard, and curl drops the request
body/method silently without it. Use `-sS` so errors still surface.

```sh
m() { curl -sSL "$B$1" -H "$H"; }   # paste-in helper for a session
```

## Discovery walk

```sh
# orgs -> pick id
m /organizations | jq -r '.[]|[.id,.name]|@tsv'

# networks in an org (id, type, name)
m "/organizations/$ORG/networks" | jq -r '.[]|[.id,((.productTypes//[])|join(",")),.name]|@tsv'

# devices in an org (serial, model, name, network)
m "/organizations/$ORG/devices" | jq -r '.[]|[.serial,.model,.name,.networkId,.lanIp]|@tsv'

# uplink addresses, filtered by serial — note quoting of serials[]
m "/organizations/$ORG/devices/uplinks/addresses/byDevice?serials\[\]=$S1&serials\[\]=$S2" \
  | jq -r '.[]|.name as $n|.uplinks[]|.interface as $i|.addresses[]|[$n,$i,.protocol,.address,.gateway,.public.address]|@tsv'
```

Network IDs: `N_...` (combined) or `L_...` (single-device). Both work as `networkId`.

## MX firewall rules — all families

All are `GET /networks/{networkId}/...`, all return `{"rules":[...]}`, all **omit the
implicit default rule** at the end. Order is significant — first match wins.

| Family | Path suffix |
|---|---|
| L3 outbound | `appliance/firewall/l3FirewallRules` |
| L7 (app/category block) | `appliance/firewall/l7FirewallRules` |
| Inbound (one-armed / VPN concentrator) | `appliance/firewall/inboundFirewallRules` |
| Cellular outbound | `appliance/firewall/cellularFirewallRules` |
| Cellular inbound | `appliance/firewall/inboundCellularFirewallRules` |
| Port forwarding | `appliance/firewall/portForwardingRules` |
| 1:1 NAT | `appliance/firewall/oneToOneNatRules` |
| 1:Many NAT | `appliance/firewall/oneToManyNatRules` |
| Site-to-site VPN firewall (org-level) | `appliance/vpnFirewallRules` |

`vpnFirewallRules` is per-network in v1 path form but governs VPN traffic; it exists only
when site-to-site VPN is configured.

### L3 / inbound / cellular rule fields

`comment` `policy`(allow|deny) `protocol`(tcp|udp|icmp|icmp6|any) `srcCidr` `srcPort`
`destCidr` `destPort` `syslogEnabled`. Ports are comma-separated lists or ranges or `any`.
`destCidr` may contain FQDNs; `srcCidr` may not.

```sh
m "/networks/$NET/appliance/firewall/l3FirewallRules" \
  | jq -r '.rules[]|[.policy,.protocol,.srcCidr,.srcPort,.destCidr,.destPort,.comment]|@tsv' \
  | column -t -s$'\t'
```

Find deny rules, or anything wide open:

```sh
m "/networks/$NET/appliance/firewall/l3FirewallRules" \
  | jq -r '.rules|to_entries[]|select(.value.policy=="allow" and (.value.srcCidr|ascii_downcase)=="any")
           |"\(.key+1)\t\(.value.destCidr):\(.value.destPort)\t\(.value.comment)"'
```

### Port forwarding / NAT

```sh
m "/networks/$NET/appliance/firewall/portForwardingRules" \
  | jq -r '.rules[]|[.name,.protocol,.uplink,.publicPort,"->",.lanIp+":"+.localPort,(.allowedIps|join(","))]|@tsv'

m "/networks/$NET/appliance/firewall/oneToManyNatRules" \
  | jq -r '.rules[]|.publicIp as $p|.uplink as $u|.portRules[]
           |[$u,$p+":"+.publicPort,"->",.localIp+":"+.localPort,.protocol,.name]|@tsv'
```

### L7 rules

`rules[].policy` is `deny` only; `rules[].type` is one of `application`,
`applicationCategory`, `host`, `port`, `ipRange`, with `value` shaped per type.

```sh
m "/networks/$NET/appliance/firewall/l7FirewallRules" \
  | jq -r '.rules[]|[.policy,.type,(.value|tostring)]|@tsv'
```

## Auditing every network in an org

Sequential, one network at a time, with a pause — see rate limits below. Networks without
an MX return 400/404; skip rather than abort.

```sh
m "/organizations/$ORG/networks" | jq -r '.[]|select(.productTypes|index("appliance"))|.id+"\t"+.name' |
while IFS=$'\t' read -r id name; do
  out=$(curl -sSL -w '\n%{http_code}' "$B/networks/$id/appliance/firewall/l3FirewallRules" -H "$H")
  code=${out##*$'\n'}; body=${out%$'\n'*}
  [ "$code" = 200 ] || { printf '%s\tSKIP %s\n' "$name" "$code"; sleep 0.2; continue; }
  printf '%s\n' "$body" | jq -r --arg n "$name" '.rules[]|[$n,.policy,.protocol,.srcCidr,.destCidr,.destPort,.comment]|@tsv'
  sleep 0.2
done
# ponytail: fixed 0.2s sleep, no 429 retry in the loop. Add Retry-After handling if you
# ever see 429 — that means >10 req/s, i.e. another app is sharing the org budget.
```

## Rate limits

- **10 req/s per organization**, shared by every app using that org's key. Burst +10 in the
  first second (30 requests over 2s), then steady state.
- **100 req/s per source IP**, shared by all clients on the IP.
- Over limit → **429** with a `Retry-After` header (seconds). Sleep exactly that long, then
  retry; back off further if it repeats.

```sh
r=$(curl -sSL -D /tmp/h -o /tmp/b -w '%{http_code}' "$B$1" -H "$H")
[ "$r" = 429 ] && sleep "$(awk 'tolower($1)=="retry-after:"{print $2+0}' /tmp/h)"
```

Config data (networks, devices, rules) changes rarely — cache it locally instead of
re-polling. For change tracking use `GET /organizations/{organizationId}/configurationChanges`
rather than diffing full rule dumps on a timer.

## Errors

| Code | Meaning |
|---|---|
| 400 | bad/missing param — also what you get for a feature the network doesn't have |
| 401 | bad API key |
| 403 | key lacks permission on that org/network, or missing OAuth scope |
| 404 | no such resource |
| 429 | rate limited — honor `Retry-After` |
| 5xx | dashboard-side; 502/504 usually means the request never reached Meraki |

Body on failure: `{"errors":["VLANs are not enabled for this network"]}` — always read it,
it names the actual cause. Required read scopes: `sdwan:config:read` (MX firewall/NAT),
`organizations:config:read` (org/network/device lists).

## Pagination

Only list/event operations paginate (clients, events, API requests). Firewall rule
endpoints do not. Params: `perPage`, `startingAfter`, `endingBefore`. The `Link` response
header (RFC5988) carries `first`/`prev`/`next`/`last` URLs — follow `rel=next` until absent.

```sh
url="$B/networks/$NET/clients?perPage=1000"
while [ -n "$url" ]; do
  curl -sSL -D /tmp/h "$url" -H "$H" | jq -c '.[]'
  url=$(sed -n 's/.*<\([^>]*\)>; *rel=next.*/\1/p' /tmp/h | head -1)
done
```

Do not construct `startingAfter` yourself; the token type varies per endpoint (timestamp or
integer id). Use the header.

## Self-check

```sh
# smallest thing that fails if auth, redirect handling, or base URI is wrong
[ "$(curl -sSL -o /dev/null -w '%{http_code}' "$B/organizations" -H "$H")" = 200 ] \
  && echo OK || echo "auth/base-URI broken"
```
