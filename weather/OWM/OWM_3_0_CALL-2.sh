#!/usr/bin/env bash

set -euo pipefail

: "${OPENWEATHER_APP_ID:?Error missing: OPENWEATHER_APP_ID}"
: "${LON:?Error missing: LON}"
: "${LAT:?Error missing: LAT}"

curl "https://api.openweathermap.org/data/3.0/onecall?lat=${LAT}&lon=${LON}&units=imperial&exclude=minutely&appid=${OPENWEATHER_APP_ID}"
