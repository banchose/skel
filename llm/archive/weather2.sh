#!/usr/bin/env bash

BASE_URL="https://api.open-meteo.com/v1/forecast"
LOCATION="latitude=42.742830&longitude=-73.801163"
CURRENT="current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,weather_code,cloud_cover,visibility,uv_index,shortwave_radiation"
HOURLY="hourly=temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m,precipitation,precipitation_probability,rain,showers,snowfall,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,visibility,cape,uv_index,shortwave_radiation,soil_temperature_0cm,vapour_pressure_deficit,evapotranspiration"
DAILY="daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,apparent_temperature_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant,uv_index_max,sunshine_duration,daylight_duration,shortwave_radiation_sum,et0_fao_evapotranspiration"
OPTIONS="past_days=3&forecast_days=5&timezone=America/New_York&temperature_unit=fahrenheit"

curl -s "${BASE_URL}?${LOCATION}&${CURRENT}&${HOURLY}&${DAILY}&${OPTIONS}"
