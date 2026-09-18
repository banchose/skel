---
name: openweather-onecall
description: OpenWeather One Call API 4.0 reference — current weather, 1min/15min/1h/1day timelines, weather alerts, pagination, units, langs. Use when calling api.openweathermap.org/data/4.0/onecall, choosing an endpoint, decoding response fields, or handling next/prev pagination.
---

# OpenWeather One Call API 4.0

Base: `https://api.openweathermap.org/data/4.0/onecall`
Auth: `appid={API key}` on every call. Requires the separate **"One Call by Call"** subscription (1,000 free calls/day; 2,000/day default cap, editable in Billing plans). Data updates every 10 min — polling faster is wasted calls.

Coordinates only. Use the Geocoding API for city/ZIP → lat/lon.

## Endpoints

| Endpoint | Covers | Records/response |
|---|---|---|
| `/current?lat=&lon=` | now | 1 |
| `/timeline/1min?lat=&lon=` | next 60 min, precipitation only | 60 |
| `/timeline/15min?lat=&lon=` | next 48 h | 50 |
| `/timeline/1h?lat=&lon=` | 47 y history + 48 h forecast | 20 |
| `/timeline/1day?lat=&lon=` | 47 y history + ~1.5 y ahead | 10 |
| `/alert/{alert_id}` | one alert's full text | 1 |

Common optional params: `units=standard|metric|imperial` (default standard = K, m/s), `lang=en|de|zh_cn|...`, `start=<unix utc>` (timeline start; defaults to now).

```bash
curl "https://api.openweathermap.org/data/4.0/onecall/timeline/1day?lat=51.5&lon=-0.1&units=metric&appid=$OWM_KEY"
```

## Response shape

All endpoints: `lat`, `lon`, `timezone`, `timezone_offset` (seconds from UTC), `data[]`, plus `next`/`prev` when paginated.

Missing field = phenomenon not measured (e.g. no `rain`, or no `sunrise`/`sunset` in polar day/night). Don't assume keys exist.

`data[]` per record, by endpoint:

- **current**: `dt sunrise sunset temp feels_like pressure humidity dew_point uvi clouds visibility wind_speed wind_deg wind_gust? rain.1h? snow.1h? weather[] alerts[]`
- **1min**: `dt precipitation alerts[]`
- **15min / 1h**: current's fields plus `pop`, minus sunrise/sunset
- **1day**: `dt sunrise sunset moonrise moonset moon_phase pressure humidity dew_point wind_speed wind_deg wind_gust weather[] clouds pop uvi` — and `temp` / `feels_like` are **objects**, not scalars:
  - `temp: {day, min, max, night, eve, morn}`
  - `feels_like: {day, night, eve, morn}` (no min/max)

Units: temps K/°C/°F by `units`; wind m/s or mph; `pressure` hPa; `humidity`/`clouds` %; `visibility` m (max 10000); `pop` 0–1; precipitation **always mm/h** regardless of `units`. `weather[]` = `{id, main, description, icon}`; icons at `https://openweathermap.org/img/wn/{icon}@2x.png`.

## Alerts

Timeline/current records carry `alerts` = array of alert **IDs** only. Fetch details per ID:

```bash
curl "https://api.openweathermap.org/data/4.0/onecall/alert/8B46C632-DCA7-44D7-8BDF-02445621BAFF?appid=$OWM_KEY"
# -> {id, sender_name, event, start, end, description}
```
English by default; some agencies only supply local language.

## Pagination

Responses cap at the per-endpoint record limit. If more data exists, the response contains ready-made absolute URLs in `next` (later) and `prev` (earlier) — follow them verbatim, don't build them. Absent field = end of data in that direction. **Each paginated request is a billed API call.**

```python
def walk(url, pages=5):          # follow next links
    import urllib.request, json
    for _ in range(pages):
        r = json.load(urllib.request.urlopen(url))
        yield from r["data"]
        url = r.get("next")
        if not url:
            return
```

## Gotchas

- All times are Unix UTC; render local time with `timezone_offset` or `timezone`.
- 1-day `temp` being a dict is the usual source of `TypeError` when reusing hourly parsing code.
- `401` = key not subscribed to One Call by Call (a plain free key won't work here).
- 4.0 paths are `/data/4.0/onecall/...` with a `data[]` array — not 3.0's `current`/`hourly`/`daily` sibling keys.
