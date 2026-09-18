#!/usr/bin/env bash
# Weather + convective-instability report, for a Pi agent to call.
# usage: call-meteo.sh [lat] [lon] [days] [--json]
# See https://open-meteo.com/en/docs
set -euo pipefail

LAT=${1:-42.74283}
LON=${2:--73.8011}
DAYS=${3:-3}
TZ_NAME=${TZ_NAME:-auto}
RAW=${4:-}

CUR=temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m,is_day,precipitation,weather_code,pressure_msl,cloud_cover,visibility,wind_speed_10m,wind_direction_10m,wind_gusts_10m,cape
HOURLY=temperature_2m,dew_point_2m,relative_humidity_2m,precipitation,showers,precipitation_probability,weather_code,cloud_cover,pressure_msl,wind_speed_10m,wind_direction_10m,wind_gusts_10m,cape,convective_inhibition,lifted_index,lightning_potential,boundary_layer_height,freezing_level_height,total_column_integrated_water_vapour,vertical_velocity_700hPa,wind_speed_850hPa,wind_direction_850hPa,wind_speed_500hPa,wind_direction_500hPa,temperature_500hPa,temperature_850hPa,geopotential_height_500hPa,geopotential_height_850hPa,relative_humidity_700hPa
DAILY=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,cape_max,cape_mean,uv_index_max,sunrise,sunset

json=$(curl -sfG 'https://api.open-meteo.com/v1/forecast' \
  --data-urlencode "latitude=$LAT" --data-urlencode "longitude=$LON" \
  --data-urlencode "current=$CUR" --data-urlencode "hourly=$HOURLY" --data-urlencode "daily=$DAILY" \
  --data-urlencode "timezone=$TZ_NAME" --data-urlencode "forecast_days=$DAYS" \
  --data-urlencode "wind_speed_unit=mph" --data-urlencode "temperature_unit=fahrenheit")

[ "$RAW" = "--json" ] && { printf '%s' "$json" | jq '.'; exit 0; }

j() { printf '%s' "$json" | jq -r "$1"; }

LIB='
  def r($n): if . == null then "-" else (. * pow(10;$n) | round) / pow(10;$n) | tostring end;
  def dir: if . == null then "-" else ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"][((. / 22.5) | round) % 16] end;
'

j "$LIB"'
  .current as $c |
  "LOCATION \(.latitude),\(.longitude)  elev \(.elevation)m  \(.timezone)  model best_match (HRRR 3km near-term over CONUS)",
  "NOW \($c.time)  \($c.temperature_2m)F (feels \($c.apparent_temperature))  dew \($c.dew_point_2m)F  RH \($c.relative_humidity_2m)%  wmo \($c.weather_code)  cloud \($c.cloud_cover)%",
  "    wind \($c.wind_speed_10m) gust \($c.wind_gusts_10m) mph from \($c.wind_direction_10m|dir)  \($c.pressure_msl)hPa  vis \(($c.visibility/1609)|r(1))mi  precip \($c.precipitation)mm  CAPE \($c.cape)",
  ""'

cat <<'EOF'
HOURLY (future hours with CAPE>=250 or precip>0)
  SHR6 = 10m->500hPa bulk shear mph (>=35 organizes storms)   SHR1 = 10m->850hPa low-level shear mph (>=25 rotation)
  LR = 850-500hPa lapse rate C/km (>=7 steep)   ASC = 700hPa vertical velocity m/s (+ = ascent/forcing)
  CIN = capping (|CIN|>150 suppresses)   LI = lifted index (negative = unstable)   PWAT mm   RH700 % (low = dry entrainment)
  SHWR = convective precip mm   LCL = mixing depth m   FRZ = freezing level m (low + high CAPE = hail)   LTNG = lightning potential (Europe only)
EOF
j "$LIB"'
  # bulk shear: vector difference between two levels
  def shear($s1;$d1;$s2;$d2):
    if ($s1 == null) or ($s2 == null) then null
    else ($d1*3.14159/180) as $a | ($d2*3.14159/180) as $b
      | ($s1*($a|sin) - $s2*($b|sin)) as $du | ($s1*($a|cos) - $s2*($b|cos)) as $dv
      | (($du*$du + $dv*$dv)|sqrt) end;
  def lapse($t8;$t5;$h8;$h5):
    if ($h5 == null) or ($h8 == null) or ($h5 - $h8) <= 0 then null
    else (($t8 - $t5) / 1.8) / (($h5 - $h8) / 1000) end;   # dF/1.8 = dC
  def verdict($cape;$cin;$s6;$s1):
    if ($cape // 0) < 250 then "stable"
    elif ($cin != null and ($cin|fabs) > 150) then "capped(CIN)"
    elif $cape >= 1000 and ($s6 // 0) >= 35 and ($s1 // 0) >= 25 then "ROTATING/tornado-capable"
    elif $cape >= 2500 and ($s6 // 0) >= 35 then "SEVERE risk"
    elif $cape >= 1000 and ($s6 // 0) >= 35 then "organized/multicell"
    elif $cape >= 2500 then "strong pulse storms"
    elif $cape >= 1000 then "pulse storms"
    else "weak convection" end;
  .current.time as $now | .hourly as $h |
  ["time","T","Td","POP","PRCP","SHWR","gust","cloud","CAPE","CIN","LI","ASC","SHR6","SHR1","LR","PWAT","RH700","LCL","FRZ","LTNG","wmo","verdict"],
  ($h.time | to_entries[].key as $i |
    select($h.time[$i] >= $now[0:13]) |
    $h.cape[$i] as $cape | $h.convective_inhibition[$i] as $cin |
    shear($h.wind_speed_10m[$i]; $h.wind_direction_10m[$i]; $h.wind_speed_500hPa[$i]; $h.wind_direction_500hPa[$i]) as $s6 |
    shear($h.wind_speed_10m[$i]; $h.wind_direction_10m[$i]; $h.wind_speed_850hPa[$i]; $h.wind_direction_850hPa[$i]) as $s1 |
    lapse($h.temperature_850hPa[$i]; $h.temperature_500hPa[$i]; $h.geopotential_height_850hPa[$i]; $h.geopotential_height_500hPa[$i]) as $lr |
    select(($cape // 0) >= 250 or ($h.precipitation[$i] // 0) > 0) |
    [$h.time[$i][5:16], ($h.temperature_2m[$i]|r(0)), ($h.dew_point_2m[$i]|r(0)),
     $h.precipitation_probability[$i], ($h.precipitation[$i]|r(1)), ($h.showers[$i]|r(1)), ($h.wind_gusts_10m[$i]|r(0)),
     $h.cloud_cover[$i], ($cape|r(0)), ($cin|r(0)), ($h.lifted_index[$i]|r(1)),
     ($h.vertical_velocity_700hPa[$i]|r(2)), ($s6|r(0)), ($s1|r(0)), ($lr|r(1)),
     ($h.total_column_integrated_water_vapour[$i]|r(0)), $h.relative_humidity_700hPa[$i],
     ($h.boundary_layer_height[$i]|r(0)), ($h.freezing_level_height[$i]|r(0)), ($h.lightning_potential[$i]|r(0)),
     $h.weather_code[$i], verdict($cape;$cin;$s6;$s1)])
  | @tsv' | column -t -s $'\t'

echo; echo DAILY
j "$LIB"'
  .daily as $d |
  ["date","Tmax","Tmin","precip_mm","POPmax","wind","gust","CAPEmax","CAPEmean","UVmax","sunrise","sunset"],
  ($d.time | to_entries[].key as $i |
    [$d.time[$i], $d.temperature_2m_max[$i], $d.temperature_2m_min[$i],
     ($d.precipitation_sum[$i]|r(1)), $d.precipitation_probability_max[$i],
     ($d.wind_speed_10m_max[$i]|r(0)), ($d.wind_gusts_10m_max[$i]|r(0)),
     ($d.cape_max[$i]|r(0)), ($d.cape_mean[$i]|r(0)), $d.uv_index_max[$i],
     $d.sunrise[$i][11:16], $d.sunset[$i][11:16]])
  | @tsv' | column -t -s $'\t'
