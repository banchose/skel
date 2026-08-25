---
name: weather
description: Current conditions, 60-minute precipitation nowcast, official weather alerts, and a convective/severe-storm outlook (CAPE, CIN, bulk shear, lapse rate, mid-level ascent) for any location. Use whenever the user asks about weather, temperature, rain, wind, storms, thunderstorms, severe weather risk, alerts/warnings, or "is it going to storm".
compatibility: Requires bash, curl, jq, column, and OPENWEATHER_APP_ID with a One Call by Call subscription. Open-Meteo needs no key. Degrades to Open-Meteo-only if OWM fails.
---

# Weather

```bash
./weather.sh                            # default location (Troy/Albany NY)
./weather.sh 39.7392 -104.9903 5        # lat lon days   (days affects the Open-Meteo blocks)
./weather.sh 42.74 -73.80 3 --json      # all raw payloads, merged
./weather.sh --selftest                 # offline check of the shear/lapse/verdict math
```

For a named place, geocode first: `curl -s 'https://geocoding-api.open-meteo.com/v1/search?name=Denver&count=1' | jq '.results[0]|{latitude,longitude}'`

## Two sources, on purpose

| block | source |
|---|---|
| LOCATION / NOW, ALERTS, NOWCAST, DAILY | OpenWeather **One Call 4.0** (OWHL model, 10-min updates) |
| NEXT 12H, CONVECTIVE | **Open-Meteo** (`best_match`; HRRR 3 km near-term over CONUS) |

One Call 4.0 carries no upper-air data at all — no CAPE, CIN, bulk shear, lapse rate, freezing level, or mid-level ascent. Those come from Open-Meteo and cannot come from OWM. Conversely Open-Meteo has no minute-level nowcast and no agency alerts. Both are needed; don't "simplify" to one.

~4 calls per run (3 OWM + 1 Open-Meteo), plus one per active alert. OWM free tier is 1000/day.

## Output blocks

1. **NOW** — temp/feels/dew/RH, plain-language condition, wind+gust+direction, cloud, pressure, UV, visibility, sun times.
2. **ALERTS** — only when active. Kind (WATCH/WARNING/ADVISORY), name, issuing office, validity window, description (600 chars).

**Watches are included**, verified against SPC Severe Thunderstorm Watches 626/627. But the API gives no structural way to tell a watch from a warning: `severity`/`urgency` do not exist and `event` is frequently an empty string on NWS products. The script derives the kind by scanning the description text (WARNING wins ties, so it escalates rather than downplays) and names the alert from `tags`. **Read the description before characterizing an alert** — never call a watch a warning.
3. **NOWCAST** — one line from the 60-minute minutely feed: when precip starts, peak intensity, how many of the 60 minutes are wet.
4. **NEXT 12H** — hourly T/feels/Td/POP/PRCP/SNOW/gust/wind/cloud/sky. Always present.
5. **CONVECTIVE** — only future hours with CAPE>=250 or precip>0. Prints its own column legend; read it, don't guess.
6. **DAILY** — up to 10 days: Tmax/Tmin/feels, POP, precip, wind, UV, RH, cloud, moon phase, sun times, condition text.

**DAILY rows are UTC day buckets, not local days.** At UTC-4 the `08-25` row covers 08-24 20:00 -> 08-25 20:00 local, so its POP/precip can reflect rain that fell last evening. For "will it rain today" prefer NEXT 12H, NOWCAST, and the CONVECTIVE table; use DAILY for the multi-day trend.

Weather codes are decoded to text (`TSTORM+hail`, `frzrain`, `snow+`, `pcloudy`) — never report a raw WMO number.

## Answering the user

- Plain weather question → NOW, NOWCAST, NEXT 12H, DAILY. Do not dump the CONVECTIVE table.
- "Will it rain right now / soon" → NOWCAST is the answer, it beats POP for the next hour.
- **An ALERTS block leads the response.** An active agency warning outranks every number below it.
- Storm/severe question → the `verdict` column is the summary; cite the hours and the numbers behind it (CAPE, SHR6, SHR1, ASC, CIN).
- Winter: rain vs snow vs freezing rain comes from `sky` and `SNOW`, not from `PRCP` alone.
- An empty CONVECTIVE table means no instability and no precip in range. Say that plainly.
- `LTNG` is `-` outside Europe (ICON-D2 only). Not a sign of calm weather.
- If stderr shows `OWM ERROR`, say so — the report is Open-Meteo-only and has no alerts or nowcast in it. Never present a degraded run as complete.
- Never invent values the tables don't have (no helicity/STP/EHI — neither API has them).

## Interpreting the verdict column

CAPE is fuel, shear organizes it, ascent triggers it, CIN suppresses it. All four matter:
high CAPE with `|CIN|>150` often produces nothing; CAPE 1000 with SHR6 45 outperforms CAPE 3000 with SHR6 10.
`FRZ` below ~3000 m with high CAPE means hail. Steep `LR` (>=7) and dry `RH700` favor strong downdrafts and wind gusts.
`PBL` is mixing depth (not LCL) — deep PBL with low dewpoints means high-based, gust-prone storms.
Hour 1–18 forecasts are far more trustworthy than day 3+.

## Known API gotchas

Verified against live 4.0 payloads — several of these contradict OWM's own docs:

- Daily `rain` is a **bare number** (mm), not `{"1h": n}` as documented. Indexing it with `."1h"` throws. The script's `mm` helper type-checks.
- Daily records have **no `summary`** field, despite the docs implying one. Condition text comes from `weather[0].description`.
- Daily and current records had **no `wind_gust`** at all; it is "where available" only.
- Daily `dt` is **midnight UTC**. Do not add `timezone_offset` to it — that labels every row one day early. Sunrise/sunset *do* need the offset.
- `visibility` caps at 10000 m, so `6.2mi` means "6.2 or better", not a measurement.
- Hourly endpoint is `timeline/1h`, **not** `1hour`. Wrong paths return 401, which looks exactly like a subscription problem.
- Record caps: `1h` → 20 records, `1day` → 10, `15min` → 50, `1min` → 60. Beyond that you must follow the `next` URL, and each page is a billed call. This script deliberately avoids OWM hourly for that reason — Open-Meteo gives 48h+ in one free call.
- Alert IDs are **`urn:oid:2.49.0.1.840.0…` strings**, not the UUIDs the docs show. They contain colons and work unencoded in the path.
- Alert `description` is an **array of `{language, description}`**, not a plain string. `gsub` on it throws. Prefer the `en*` entry.
- Alert `event` is often **`""`** (empty) on NWS watches; an undocumented `tags` array (e.g. `["Thunderstorm"]`) carries the category instead.
- `data[].alerts` is an array of alert IDs, not objects; the key is **absent entirely** when nothing is active. Details need `/onecall/alert/{id}`.
- OWM alerts have **no severity/urgency field** (unlike NWS CAP).
- OWM omits fields that are zero/absent, so always use `// 0` style fallbacks.
- New OWM API keys take **up to 2 hours** to activate, and return the generic "requires a separate subscription" 401 until they do.
