---
name: weather
description: Current conditions plus convective/severe-storm outlook (CAPE, CIN, bulk shear, lapse rate, mid-level ascent) for any location, from the Open-Meteo API. Use whenever the user asks about weather, temperature, rain, wind, storms, thunderstorms, severe weather risk, or "is it going to storm".
compatibility: Requires bash, curl, jq, and column. No API key.
---

# Weather

```bash
./weather.sh                            # default location, 3 days
./weather.sh 39.7392 -104.9903 5        # lat lon days
TZ_NAME=America/Denver ./weather.sh 39.7392 -104.9903
./weather.sh 42.74 -73.80 3 --json      # raw API JSON
```

Default location is Troy/Albany NY (42.74283, -73.8011). Timezone defaults to `auto` (resolved from the coordinates), override with `TZ_NAME`.
For a named place, geocode first: `curl -s 'https://geocoding-api.open-meteo.com/v1/search?name=Denver&count=1' | jq '.results[0]|{latitude,longitude}'`

Output is three blocks: LOCATION/NOW, an HOURLY table (only future hours with CAPE>=250 or precip>0), and DAILY. The script prints its own column legend — read it, don't guess at the abbreviations.

## Answering the user

- Plain weather question → answer from NOW and DAILY. Do not dump the hourly table.
- Storm/severe question → the hourly `verdict` column is the summary; cite the hours and the numbers that drove it (CAPE, SHR6, SHR1, ASC, CIN).
- An empty hourly table means no instability and no precip in range. Say that plainly.
- `LTNG` is always `-` outside Europe (ICON-D2 only). `SHWR` may be 0 even during storms on some models. Neither is a sign of calm weather.
- Never invent values the table doesn't have (no helicity/STP/EHI — the API has none).

## Interpreting the verdict column

CAPE is fuel, shear organizes it, ascent triggers it, CIN suppresses it. All four matter:
high CAPE with `|CIN|>150` often produces nothing; CAPE 1000 with SHR6 45 outperforms CAPE 3000 with SHR6 10.
`FRZ` below ~3000 m with high CAPE means hail. Steep `LR` (>=7) and dry `RH700` favor strong downdrafts and wind gusts.

Model is `best_match`: HRRR at 3 km for near-term CONUS, global models beyond. Hour 1-18 forecasts are far more trustworthy than day 3+.
