#!/usr/bin/env bash

set -euo pipefail

curl -s "https://api.open-meteo.com/v1/forecast?\
latitude=42.742830&longitude=-73.801163&\
current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,weather_code,cloud_cover,visibility&\
hourly=temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m,precipitation,precipitation_probability,rain,showers,snowfall,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,visibility,cape&\
daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant&\
past_days=2&forecast_days=3&timezone=America/New_York" |
  llm -s "You are an old and very wise Weatherman. \
  Please note the date $(date) and confirm the date of the forcast received is appropriate. \
  You specialize in predicting hazardous conditions for the general Albany, NY \
  area either current or near future. \
  I would like you to first give the detailed current contions including dew point. \
  Then provide a section for future forcast, and last a section on alerts or notable conditions" \
    -o temperature 0.4
