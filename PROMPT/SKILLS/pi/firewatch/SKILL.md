---
name: firewatch
description: Live US wildfire incidents (NIFC WFIGS, 15-min refresh) via the FireWatch MCP endpoint — search active fires by state/acreage, get incident detail, list containment updates. Use when asked about wildfires, fire perimeters, containment, acres burned, or fire activity near a place.
---

# FireWatch

Public MCP endpoint, no auth. Call it with curl — do not register it as an MCP server.

```
EP=https://firewatch-mcp.lovable.app/api/public/mcp
fw() { local a=${2:-'{}'}
  curl -s -X POST $EP -H 'Content-Type: application/json' \
  -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"tools/call\",\"params\":{\"name\":\"$1\",\"arguments\":$a}}" \
  | jq -r '.result.content[0].text | fromjson'; }
```

## Tools

- `search_fires` — `{state:"CA", min_acres:1000, active_only:true, limit:50}`, all optional.
  Returns `{count, fires:[{id,name,state,county,acres,containment_pct,latitude,longitude,is_active,discovered_at,updated_at}]}`
- `get_fire` — `{id:"<uuid>"}` — full detail + recent updates.
- `list_updates` — `{fire_id, since:"2026-08-01T00:00:00Z", limit}`, all optional.

## Examples

```
fw search_fires '{"state":"CA","min_acres":5000,"limit":10}'
fw get_fire '{"id":"85b5931b-aaf3-4f68-9104-3a53cfc8e421"}'
fw list_updates '{"since":"2026-08-30T00:00:00Z","limit":20}'

# one line per fire
fw search_fires '{"state":"CA","min_acres":1000}' \
  | jq -r '.fires[] | "\(.acres)ac \(.containment_pct // "n/a")% \(.name) — \(.county)"'
```

## Notes

- `containment_pct` is often `null` on small incidents. Default to `min_acres: 1000` — a state query otherwise returns dozens of <20ac grass fires and `count` silently caps at `limit`.
- Fires sort by acres descending. No radius/bbox filter — filter by state, then compare lat/lon yourself for "near me".
- US only. Not an emergency service; for anything actionable, point the user at local authorities and InciWeb.
