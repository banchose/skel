---
name: tomtom-maps
description: Gotchas and worked examples for the tomtom-maps MCP server — geocoding, POI and EV search, routing, traffic incidents, static map images and GeoJSON visualization. Covers the [lon, lat] coordinate trap that silently returns Antarctica, tools that need a category to return anything, filters that silently zero results, and which endpoints the API key can't reach. Use when asked to geocode an address, find places or EV chargers near somewhere, plan a driving route or travel time, check traffic or road closures, or render a map.
---

# tomtom-maps MCP

30 tools, all prefixed `tomtom-maps_`. **Only 15 are real endpoints** — the other 15 are
`read_ui_*` resource readers that just return the HTML of the interactive map widget. Ignore
them unless you're debugging the UI.

Reads only, no billing risk per call, but **two endpoints are not licensed on this key** (see
"Endpoints the key can't reach"). Data is live for traffic and EV availability.

## Tool routing

| Question | Tool |
|---|---|
| "where is <address>" | `tomtom-geocode` |
| "what's at these coordinates" | `tomtom-reverse-geocode` |
| "find <business/brand>", "all restaurants" | `tomtom-poi-search` |
| typo'd or half-remembered query | `tomtom-fuzzy-search` |
| "what's near here" (no query) | `tomtom-nearby` — **needs `poiCategories`** |
| "all X strictly inside this area" | `tomtom-area-search` |
| category code for a word | `tomtom-poi-categories` |
| EV chargers + live availability | `tomtom-ev-search` |
| "gas stations on the way" | `tomtom-search-along-route` |
| directions, travel time, distance, multi-stop | `tomtom-routing` |
| traffic, accidents, closures | `tomtom-traffic` |
| render a map image with pins/routes | `tomtom-dynamic-map` |
| plot my own GeoJSON | `tomtom-data-viz` |
| how far can I get in 30 min | `tomtom-reachable-range` — ❌ not licensed |
| EV route with charging stops | `tomtom-ev-routing` — ❌ not licensed |

`tomtom-routing` handles A→B and multi-stop in one call via an ordered `locations` array —
don't chain per-leg calls.

## Coordinates are `[lon, lat]` — and getting it wrong fails silently

Every array-shaped coordinate parameter is **GeoJSON order: `[longitude, latitude]`**. There is
no validation. Passing `[lat, lon]` for Washington DC returns, with `ok: true` and no warning:

```
position: [38.8977, -77.0365]  →  "country": "Antarctica", "countryCode": "AQ"
```

Because 38.9°E / 77°S is a real place in the Southern Ocean. The same swap makes `poi-search`
return `totalResults: 0` — the geo-bias was in Antarctica, so "no coffee found" looked like a
data gap rather than a bug. **A surprising empty result is a swapped-coordinate suspect first.**

Applies to `position`, `origin`, `destination`, `center`, `locations[]`, `waypoints[]`, and
`bbox` (`[minLon, minLat, maxLon, maxLat]`).

**`tomtom-dynamic-map` is the exception** — it takes `{lat, lon}` *objects*, so the field names
protect you there. Don't carry the object form to any other tool.

```js
const DC = [-77.0365, 38.8977];                    // arrays: lon first
const dcObj = { lat: 38.8977, lon: -77.0365 };     // dynamic-map only
```

Shapes are inconsistent in one more place: `area-search` types `boundingBox` as `number[][]`
(corner pairs) while `traffic` types `bbox` as a flat `number[]`. Check the schema per tool.

## Calling convention

In `mcpScript`, the path is the **full underscore name** — `tomtom-maps_tomtom-geocode`. The
slash form `tomtom-maps/tomtom-geocode` returns `tool_not_found` (it does suggest the right
name, but that's a wasted round trip).

Payload is at **`data.content[0].text` as a JSON string** — parse it:

```js
const r = await tools.call('tomtom-maps_tomtom-geocode',
  { query: '1600 Pennsylvania Ave NW, Washington DC', limit: 1,
    response_detail: 'compact', show_ui: false });
const j = JSON.parse(r.data.content[0].text);
emit(j.features[0].geometry.coordinates);          // [-77.0365431, 38.8977018]
```

Two options exist on nearly every tool and you almost always want both:

- **`show_ui: false`** — skip the interactive widget. **Always pass this explicitly**; see
  "Never set `show_ui: true` on a headless host" below.
- **`response_detail: 'compact'`** — trims geometry/boundary coordinates. Responses are GeoJSON
  and get fat fast.

For `tomtom-routing` add **`routeRepresentation: 'summaryOnly'`** unless you need the polyline.

Most search tools take `limit` and `ofs` for paging. `totalResults` **caps at 100** — it's not a
true count, so don't report it as "there are 100 X nearby."

## Never set `show_ui: true` on a headless host

The tool schemas say *"Set to true when visualization is needed for the user"* — **ignore that
advice here.** `show_ui: true` makes the server return a `ui://tomtom-*` resource and the harness
tries to launch a browser to render it. On a headless, container, or SSH host that fails and
dumps noise into the transcript:

```
Warning: MCP UI browser open failed: Failed to open browser (exit code 1)
Warning: Couldn't open MCP UI here. Open it from your own device:
  http://localhost:8379/?session=…
SSH: run `ssh -L 8379:127.0.0.1:8379 -L 35191:127.0.0.1:35191 <this-host>` …
```

**The tool call itself still succeeded** — this is cosmetic, the data came back. But it clutters
output and dangles a URL the user usually can't reach, so pass `show_ui: false` on *every* call
and never flip it on just because the request sounds map-shaped.

When the user genuinely wants something visual, in order of preference:

1. **Report the numbers** — distance, time, delay, names. Usually what they actually wanted.
2. **`tomtom-dynamic-map` with `show_ui: false`** — renders a JPEG server-side and spills it to
   `fullResultPath`; hand over that path. No browser needed.
3. **Only if they ask for the interactive widget:** tell them it needs the port-forward from the
   warning (`ssh -L 8379:127.0.0.1:8379 -L 35191:127.0.0.1:35191 <host>`, then open the URL),
   and note **mosh cannot forward ports** — that command must run in a separate real `ssh`
   session. Set `show_ui: true` only after they've set that up.

## `nearby` returns nothing without a category

`tomtom-nearby` has no `query`, so with no category there's nothing to match — it returns
`totalResults: 0`, `ok: true`, no error. Verified in downtown DC:

| Call | Result |
|---|---|
| `{position: DC, radius: 800}` | **0 results** |
| `{position: DC, radius: 800, poiCategories: ['RESTAURANT']}` | 100 → Old Ebbitt Grill, … |
| `{position: DC, poiCategories: ['RESTAURANT']}` (no radius) | identical 100 |

`radius` is not what fixes it and is not required. Get codes from `tomtom-poi-categories`
(`{filters: ['restaurant']}` → `RESTAURANT` plus ~80 child codes like `ITALIAN_RESTAURANT`);
they're uppercase snake-case strings, not the numeric IDs some tool descriptions mention.

## `ev-search`: `minPowerKW` is broken, sparse data looks like a bug

Works bare (`{position: DC}` → Blink, Tesla, …). Two filters need care:

- **`minPowerKW` returns 0 results at every value tested** — 1, 7, 22, 50, 150, and also when
  paired with `maxPowerKW`. At `minPowerKW: 1` the returned data itself contains 6, 7 and 11 kW
  connectors, so this filter is broken, not selective. **Don't use it.** `maxPowerKW` alone works
  fine. To filter by power, pull `chargingPark.connectors[].connector.ratedPowerKW` from a
  `response_detail: 'full'` response and filter client-side.
- **`connectorTypes` works, but connector coverage is thin and a bogus value fails silently.**
  `['NotAConnector']` → 0 results, no error, same as a legitimately empty area.

Sparse data reads exactly like a broken filter. Nearest `IEC62196Type2CCS` to central DC is
**149 km away**, so `connectorTypes: ['IEC62196Type2CCS'], radius: 5000` → 0 is *correct*.
Confirm by dropping `radius` and reading `properties.distance` on the first hit before concluding
anything is broken. Valid values include `IEC62196Type2CCS`, `IEC62196Type2CableAttached`,
`IEC62196Type2Outlet`, `IEC62196Type1`, `Tesla`, `Chademo`.

`includeAvailability: true` is safe to combine with anything.

## `bbox` in a response is the result extent, not the search area

Responses carry a `bbox` covering the **returned features**, so a 5 km-radius search that
matched three clustered POIs reports a ~500 m box. That is not evidence `radius` was ignored.
Use `properties.distance` (metres from `position`) to check how far results actually are.

## `search-along-route` returns a nested shape

Alone among the search tools, it does **not** parse to a bare FeatureCollection — there's no
top-level `properties.totalResults`, and looking for one makes a good response read as empty:

```js
const j = JSON.parse(r.data.content[0].text);
// { route, pois, summary, _meta }
j.route.features[0].properties.summary;              // lengthInMeters, travelTimeInSeconds, …
j.pois.features.map(f => f.properties.poi.name);     // ['Shell', 'Sunoco', …]
```

It's the slowest endpoint (routes, then searches a corridor). A 66 km route with
`corridorWidth: 1000` timed out; 10 km with `corridorWidth: 500` returned fine. Keep routes and
corridors tight, and prefer `limit: 3–5`.

## `traffic` self-truncates and tells you

Returns severity-ranked incidents plus a summary — no manual paging needed:

```js
const r = await tools.call('tomtom-maps_tomtom-traffic',
  { bbox: [-77.12, 38.79, -76.91, 38.99], maxResults: 3,
    response_detail: 'compact', show_ui: false });
const { incidents, incidentSummary } = JSON.parse(r.data.content[0].text);
// incidentSummary: { totalIncidents: 292, returnedIncidents: 3, truncated: true,
//                    incidentsByIconCategory: { '6': 246, '8': 36, '9': 8, … } }
```

Report `totalIncidents` for scale and the incidents themselves for detail. `magnitudeOfDelay`
and `events` (e.g. `['Closed']`) are the useful per-incident fields; `iconCategory` 6 is
jam/congestion and 8 is closure, which dominate normal city bboxes.

## `dynamic-map` returns a ~176 KB JPEG and trips the output guard

At 600×400 with one marker the result is **176 KB**, well over the harness limit. `r.ok` stays
`true` but `r.data` has **no `content`** — instead:

```
omitted, reason, isError, contentBlocks, contentSummary, rawResultBytes, fullResultPath
```

So `r.data.content[0].text` throws `TypeError: Cannot read properties of undefined (reading '0')`
— a type error, not a size error. **Guard it, and don't inspect the image in-script:**

```js
if (r.data.omitted) emit({ img: r.data.fullResultPath, bytes: r.data.rawResultBytes });
```

The image is for the user, not for you — it's a JPEG you can't read anyway. Call it with
`show_ui: false` and hand over the file path; **do not** reach for `show_ui: true` to render it.
`mcpScript` has no `fs`/`require`, so read the spill with bash if needed:

```bash
jq -r '.content[] | select(.type=="text") | .text' /tmp/pi-mcp-output-*/mcp-result-*.txt
```

`tomtom-data-viz` is the opposite — it returns a small JSON *summary* (`feature_count`, `bbox`,
`property_names`, `viz_id`) and renders your GeoJSON in the widget. Pass `geojson` as a
**string**, not an object:

```js
await tools.call('tomtom-maps_tomtom-data-viz', {
  geojson: JSON.stringify(fc),
  layers: [{ type: 'markers', label_property: 'name', color_property: 'val' }],
  title: 'DC test', show_ui: false });
```

## Endpoints the key can't reach

`tomtom-reachable-range` (isochrones) and `tomtom-ev-routing` both fail **instantly**:

```
tool_error: "Your TomTom API key may be invalid, expired, or missing permissions for this request"
```

followed by a dump of every parameter — which reads like a validation error but isn't. The key
works on Search, Routing and Traffic, so this is a **missing product entitlement**, not a bad
argument and not distance-related (a 66 km EV route fails as fast as a 700 km one). No parameter
tweak helps. Say the endpoint isn't licensed and offer the alternative:

- reachable-range → describe distances with `tomtom-routing` to a few sample points.
- ev-routing → plain `tomtom-routing` plus `tomtom-ev-search` near the midpoint.

## Failures arrive in three different shapes

None of these raise an exception, and only one is a real error object:

| Shape | Looks like | Cause |
|---|---|---|
| `{ok: false, error: {code: 'tool_error'}}` | server rejected it | entitlement, bad params |
| `{ok: false, error: {code: 'call_failed', message: 'Request timed out'}}` | gateway gave up | heavy routing/corridor calls |
| script-level `This operation was aborted` | whole `mcpScript` killed | very slow call; raising `timeoutMs` to 180 s did **not** help |
| `{ok: true}` with `totalResults: 0` | "nothing there" | swapped coordinates, missing category, or broken `minPowerKW` |

The last row is the dangerous one — a silent wrong answer. Check coordinate order and category
before believing an empty result.

## Timestamps are unreliable

`routing` returns `departureTime` / `arrivalTime` resolved against a server clock that reported
**2026** dates during testing. Durations (`travelTimeInSeconds`, `trafficDelayInSeconds`) are
sound; absolute timestamps are not. Report "about 1 h 48 min" and, if you need a wall-clock ETA,
get the current time from the `time` MCP server rather than echoing `arrivalTime`.

## Worked example: geocode then route

The common two-step — resolve names to coordinates, then route through them. One script, no
intermediate reporting.

```js
const geo = async q => {
  const r = await tools.call('tomtom-maps_tomtom-geocode',
    { query: q, limit: 1, response_detail: 'compact', show_ui: false });
  return JSON.parse(r.data.content[0].text).features[0].geometry.coordinates;  // [lon, lat]
};

const stops = [];
for (const q of ['White House, Washington DC', 'Inner Harbor, Baltimore MD'])
  stops.push(await geo(q));

const r = await tools.call('tomtom-maps_tomtom-routing', {
  locations: stops, traffic: 'live', routeRepresentation: 'summaryOnly',
  response_detail: 'compact', show_ui: false });
const s = JSON.parse(r.data.content[0].text).features[0].properties.summary;
emit({ km: +(s.lengthInMeters / 1000).toFixed(1),
       min: Math.round(s.travelTimeInSeconds / 60),
       delayMin: Math.round(s.trafficDelayInSeconds / 60) });
// { km: 66.1, min: 108, delayMin: 6 }
```

Geocode returns `[lon, lat]` already — feed it straight into `locations` without reordering.

## Reporting conventions

- Give distances in km/miles and durations in hours/minutes, not raw metres and seconds.
- Call out `trafficDelayInSeconds` separately when non-zero — it's the part that changes hourly.
- Don't quote `arrivalTime` as a clock time (see "Timestamps are unreliable").
- `totalResults: 100` means "at least 100", not exactly 100.
- For EV availability, say when it was checked — that data is live and moves.
- If a result is empty, verify coordinate order before telling the user there's nothing there.
