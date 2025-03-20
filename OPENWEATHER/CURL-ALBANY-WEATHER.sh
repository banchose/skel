#!/usr/bin/env bash

set -euo pipefail
# Albany
LON=-73.7545
LAT=42.6518
UNITS=standard
# UNITS=metric
# alias getweather='curl "https://api.openweathermap.org/data/3.0/onecall?lat=${LAT}&lon=${LON}&exclude=minutely,hourly,daily&appid=${OPENWEATHER_APP_ID}"'

curl "https://api.openweathermap.org/data/3.0/onecall?units=${UNITS}&lat=${LAT}&lon=${LON}&exclude=minutely,hourly,daily&appid=${OPENWEATHER_APP_ID}"
# curl "https://api.openweathermap.org/data/3.0/onecall?units=${UNITS}&lat=${LAT}&lon=${LON}&exclude=minutely,hourly,daily&appid=${OPENWEATHER_APP_ID}" \
# | jq '.'
