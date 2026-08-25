#!/usr/bin/env bash
# Weather report for a Pi agent: OpenWeather One Call 4.0 for conditions/nowcast/daily/alerts,
# Open-Meteo for the convective parameters OWM does not carry (CAPE, shear, lapse rate, ...).
#
# usage: weather.sh [lat] [lon] [days] [--json|--selftest]
# needs: OPENWEATHER_APP_ID (One Call by Call subscription), bash, curl, jq, column
#
# Calls per run: 3 OWM (current, 1min, 1day) + 1 Open-Meteo + 1 per active alert.
set -euo pipefail

LAT=${1:-42.74283}
LON=${2:--73.8011}
DAYS=${3:-3}
RAW=${4:-}
OWM=https://api.openweathermap.org/data/4.0/onecall

LIB='
  def r($n): if . == null then "-" else (. * pow(10;$n) | round) / pow(10;$n) | tostring end;
  # OWM sends precip as a bare number on daily records and as {"1h":n} elsewhere
  def mm: if . == null then null elif type == "object" then ."1h" else . end;
  # alert .description is an array of {language,description} (docs claim a plain string)
  def dsc: (.description // "") |
    if type == "array" then ((map(select(.language|tostring|startswith("en"))) | .[0].description) // .[0].description // "")
    else . end | tostring | gsub("[[:space:]]+";" ");
  # .event is often "" on NWS watches, so name the alert from tags and scan the text
  # for the watch/warning distinction the API does not expose structurally.
  # ponytail: substring scan; WARNING wins ties so we escalate rather than downplay.
  def kind: (dsc | ascii_upcase) |
    if test("WARNING") then "WARNING" elif test("WATCH") then "WATCH"
    elif test("ADVISORY") then "ADVISORY" elif test("STATEMENT") then "STATEMENT" else "ALERT" end;
  def aname: if ((.event // "") | length) > 0 then .event
    elif ((.tags // []) | length) > 0 then (.tags | join("/"))
    else "unnamed" end;
  def lt($o): if . == null then "-" else (. + $o) | strftime("%Y-%m-%dT%H:%M") end;
  def dir: if . == null then "-" else ["N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"][((. / 22.5) | round) % 16] end;
  def moon: if . == null then "-" elif . < 0.03 or . > 0.97 then "new" elif . < 0.22 then "waxcres"
    elif . < 0.28 then "1stQ" elif . < 0.47 then "waxgib" elif . < 0.53 then "FULL"
    elif . < 0.72 then "wangib" elif . < 0.78 then "3rdQ" else "wancres" end;
  def wx: if . == null then "-" else {
    "0":"clear","1":"mclear","2":"pcloudy","3":"overcast","45":"fog","48":"rimefog",
    "51":"drizzle-","53":"drizzle","55":"drizzle+","56":"frzdrizzle","57":"frzdrizzle+",
    "61":"rain-","63":"rain","65":"rain+","66":"frzrain","67":"frzrain+",
    "71":"snow-","73":"snow","75":"snow+","77":"snowgrains",
    "80":"showers-","81":"showers","82":"showers+","85":"snowshwr-","86":"snowshwr+",
    "95":"TSTORM","96":"TSTORM+hail","99":"TSTORM+hail!"
  }[tostring] // ("wmo"+tostring) end;
  # bulk shear: vector difference between two levels
  def shear($s1;$d1;$s2;$d2):
    if ($s1 == null) or ($s2 == null) then null
    else ($d1*3.14159265/180) as $a | ($d2*3.14159265/180) as $b
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
'

# --- self-check for the non-trivial math (no network) -------------------------
if [ "$RAW" = "--selftest" ] || [ "${1:-}" = "--selftest" ]; then
  jq -ne "$LIB"'
    (shear(10;0;10;180) | . - 20 | fabs < 0.001) as $a |     # opposing 10mph winds -> 20mph shear
    (shear(10;90;10;90) | . < 0.001) as $b |                 # identical winds -> no shear
    (lapse(50;-40;1500;5500) | . - 12.5 | fabs < 0.001) as $c |  # 50C over 4km -> 12.5 C/km
    (verdict(1500;-10;40;30) == "ROTATING/tornado-capable") as $d |
    (verdict(3000;-200;40;30) == "capped(CIN)") as $e |
    (verdict(100;0;50;50) == "stable") as $f |
    (95 | wx) == "TSTORM" and (0.5 | moon) == "FULL" and ($a and $b and $c and $d and $e and $f)
    | if . then "selftest OK" else error("SELFTEST FAILED") end' 
  exit 0
fi

: "${OPENWEATHER_APP_ID:?OPENWEATHER_APP_ID not set}"

# --- fetch -------------------------------------------------------------------
# Prints body on HTTP 200. On anything else prints OWM's own error to stderr and fails,
# so a dead OWM call is visible, never silently blank.
fetch() {
  local url=$1 raw code body safe
  safe=${url##*/onecall/}; safe=${safe%%\?*}          # path only - never echo appid
  raw=$(curl -s --max-time 15 -w $'\n%{http_code}' "$url") || { echo "CURL FAILED: $safe" >&2; return 1; }
  code=${raw##*$'\n'}; body=${raw%$'\n'*}
  if [ "$code" != 200 ]; then
    local safe=${url##*/onecall/}; safe=${safe%%\?*}    # never echo appid
    printf 'OWM ERROR %s on %s: %s\n' "$code" "$safe" \
      "$(printf '%s' "$body" | jq -r '.message // "no message"' 2>/dev/null)" >&2
    return 1
  fi
  printf '%s' "$body"
}
u() { printf '%s/%s?lat=%s&lon=%s&units=imperial&appid=%s' "$OWM" "$1" "$LAT" "$LON" "$OPENWEATHER_APP_ID"; }

cur=$(fetch "$(u current)")           || cur=
nowc=$(fetch "$(u timeline/1min)")    || nowc=
day=$(fetch "$(u timeline/1day)")     || day=

OM_HOURLY=temperature_2m,apparent_temperature,dew_point_2m,relative_humidity_2m,precipitation,rain,showers,snowfall,precipitation_probability,weather_code,cloud_cover,uv_index,wind_speed_10m,wind_direction_10m,wind_gusts_10m,cape,convective_inhibition,lifted_index,lightning_potential,boundary_layer_height,freezing_level_height,total_column_integrated_water_vapour,vertical_velocity_700hPa,wind_speed_850hPa,wind_direction_850hPa,wind_speed_500hPa,wind_direction_500hPa,temperature_500hPa,temperature_850hPa,geopotential_height_500hPa,geopotential_height_850hPa,relative_humidity_700hPa
om=$(curl -sfG 'https://api.open-meteo.com/v1/forecast' \
  --data-urlencode "latitude=$LAT" --data-urlencode "longitude=$LON" \
  --data-urlencode "current=temperature_2m" --data-urlencode "hourly=$OM_HOURLY" \
  --data-urlencode "timezone=${TZ_NAME:-auto}" --data-urlencode "forecast_days=$DAYS" \
  --data-urlencode "wind_speed_unit=mph" --data-urlencode "temperature_unit=fahrenheit") || om=

# alert IDs live on every record; the current record's set is what's active now
ids=$(printf '%s' "${cur:-{\}}" | jq -r '.data[0].alerts[]? // empty' | sort -u)
alerts='[]'
for id in $ids; do
  a=$(fetch "$OWM/alert/$id?appid=$OPENWEATHER_APP_ID") || continue
  alerts=$(printf '%s\n%s' "$alerts" "$a" | jq -s '.[0] + [.[1]]')
done

if [ "$RAW" = "--json" ]; then
  jq -n --argjson c "${cur:-null}" --argjson m "${nowc:-null}" --argjson d "${day:-null}" \
        --argjson a "$alerts" --argjson o "${om:-null}" \
        '{owm_current:$c, owm_1min:$m, owm_1day:$d, alerts:$a, open_meteo:$o}'
  exit 0
fi

[ -n "$cur$om" ] || { echo "no data from either source (see errors above)" >&2; exit 1; }

# --- NOW ---------------------------------------------------------------------
if [ -n "$cur" ]; then
  printf '%s' "$cur" | jq -r "$LIB"'
    .timezone_offset as $o | .data[0] as $c |
    "LOCATION \(.lat),\(.lon)  \(.timezone)  OWM One Call 4.0 (OWHL model, 10-min updates) + Open-Meteo convective",
    "NOW \($c.dt|lt($o)) local  (OWM observation time)  \($c.temp|r(0))F (feels \($c.feels_like|r(0)))  dew \($c.dew_point|r(0))F  RH \($c.humidity)%  \($c.weather[0].description)",
    "    wind \($c.wind_speed|r(0)) gust \($c.wind_gust|r(0)) mph from \($c.wind_deg|dir)  cloud \($c.clouds)%  \($c.pressure)hPa  UV \($c.uvi)  vis \((($c.visibility//0)/1609)|r(1))mi" +
      (if (($c.rain|mm) // ($c.snow|mm)) then "  precip \((($c.rain|mm) // ($c.snow|mm)))mm/h" else "" end),
    "    sun \($c.sunrise|lt($o)|.[11:]) -> \($c.sunset|lt($o)|.[11:])"'
else
  echo "LOCATION $LAT,$LON  (OWM unavailable - see errors above; Open-Meteo blocks only)"
  [ -n "$om" ] && printf '%s' "$om" | jq -r '"REFERENCE TIME \(.current.time) local  (Open-Meteo; OWM current conditions and dew point unavailable)"'
fi

# --- ALERTS ------------------------------------------------------------------
if [ "$(printf '%s' "$alerts" | jq 'length')" != 0 ]; then
  echo; echo "ALERTS (national agency, via OWM)"
  printf '%s' "$alerts" | jq -r --argjson o "$(printf '%s' "$cur" | jq '.timezone_offset')" "$LIB"'
    .[] | "  \(kind)  \(aname)  [\(.sender_name)]  \(.start|lt($o)) -> \(.end|lt($o))",
          "    \(dsc | .[0:600])"'
fi

# --- 60-MINUTE NOWCAST -------------------------------------------------------
if [ -n "$nowc" ]; then
  echo; printf '%s' "$nowc" | jq -r "$LIB"'
    .timezone_offset as $o | [.data[] | select((.precipitation // 0) > 0)] as $wet |
    if ($wet|length) == 0 then "NOWCAST  no precipitation in the next 60 minutes"
    else "NOWCAST  precip starts \($wet[0].dt|lt($o)), peak \([$wet[].precipitation]|max|r(1))mm/h, \($wet|length) of 60 min wet"
    end'
fi

# --- NEXT 12H + convective (Open-Meteo) --------------------------------------
if [ -n "$om" ]; then
  o() { printf '%s' "$om" | jq -r "$LIB$1"; }
  echo; echo "NEXT 12H"
  o '
    .current.time as $now | .hourly as $h |
    ["time","T","feels","Td","POP","PRCP","SNOW","gust","wind","cloud","UV","sky"],
    ([$h.time | to_entries[].key | select($h.time[.] >= $now[0:13])][0:12][] as $i |
      [$h.time[$i][5:16], ($h.temperature_2m[$i]|r(0)), ($h.apparent_temperature[$i]|r(0)),
       ($h.dew_point_2m[$i]|r(0)), $h.precipitation_probability[$i], ($h.precipitation[$i]|r(1)),
       ($h.snowfall[$i]|r(1)), ($h.wind_gusts_10m[$i]|r(0)),
       "\($h.wind_speed_10m[$i]|r(0))\($h.wind_direction_10m[$i]|dir)",
       $h.cloud_cover[$i], ($h.uv_index[$i]|r(1)), ($h.weather_code[$i]|wx)])
    | @tsv' | column -t -s $'\t'

  echo
  cat <<'EOF'
CONVECTIVE (future hours with CAPE>=250 or precip>0)
  SHR6 = 10m->500hPa bulk shear mph (>=35 organizes storms)   SHR1 = 10m->850hPa low-level shear mph (>=25 rotation)
  LR = 850-500hPa lapse rate C/km (>=7 steep)   ASC = 700hPa vertical velocity m/s (+ = ascent/forcing)
  CIN = capping (|CIN|>150 suppresses)   LI = lifted index (negative = unstable)   PWAT mm   RH700 % (low = dry entrainment)
  PBL = mixing depth m   FRZ = freezing level m (low + high CAPE = hail)   LTNG = lightning potential (Europe only)
EOF
  o '
    .current.time as $now | .hourly as $h |
    ["time","T","Td","POP","PRCP","SNOW","gust","cloud","CAPE","CIN","LI","ASC","SHR6","SHR1","LR","PWAT","RH700","PBL","FRZ","LTNG","sky","verdict"],
    ($h.time | to_entries[].key as $i |
      select($h.time[$i] >= $now[0:13]) |
      $h.cape[$i] as $cape | $h.convective_inhibition[$i] as $cin |
      shear($h.wind_speed_10m[$i]; $h.wind_direction_10m[$i]; $h.wind_speed_500hPa[$i]; $h.wind_direction_500hPa[$i]) as $s6 |
      shear($h.wind_speed_10m[$i]; $h.wind_direction_10m[$i]; $h.wind_speed_850hPa[$i]; $h.wind_direction_850hPa[$i]) as $s1 |
      lapse($h.temperature_850hPa[$i]; $h.temperature_500hPa[$i]; $h.geopotential_height_850hPa[$i]; $h.geopotential_height_500hPa[$i]) as $lr |
      select(($cape // 0) >= 250 or ($h.precipitation[$i] // 0) > 0) |
      [$h.time[$i][5:16], ($h.temperature_2m[$i]|r(0)), ($h.dew_point_2m[$i]|r(0)),
       $h.precipitation_probability[$i], ($h.precipitation[$i]|r(1)), ($h.snowfall[$i]|r(1)), ($h.wind_gusts_10m[$i]|r(0)),
       $h.cloud_cover[$i], ($cape|r(0)), ($cin|r(0)), ($h.lifted_index[$i]|r(1)),
       ($h.vertical_velocity_700hPa[$i]|r(2)), ($s6|r(0)), ($s1|r(0)), ($lr|r(1)),
       ($h.total_column_integrated_water_vapour[$i]|r(0)), $h.relative_humidity_700hPa[$i],
       ($h.boundary_layer_height[$i]|r(0)), ($h.freezing_level_height[$i]|r(0)), ($h.lightning_potential[$i]|r(0)),
       ($h.weather_code[$i]|wx), verdict($cape;$cin;$s6;$s1)])
    | @tsv' | column -t -s $'\t'
fi

# --- DAILY (OWM) -------------------------------------------------------------
# NB: daily .dt is a midnight-UTC day bucket - label it in UTC, never shifted by
# timezone_offset, or every row comes out one day off.
# NB: OWM 4.0 daily .uvi read 0 on every record while current.uvi was nonzero, so
# UV is taken from Open-Meteo in NEXT 12H instead of from this block.
if [ -n "$day" ]; then
  echo; echo "DAILY"
  printf '%s' "$day" | jq -r "$LIB"'
    .timezone_offset as $o |
    ["date","Tmax","Tmin","feels_day","POP","precip","wind","RH","cloud","moon","sunrise","sunset","sky"],
    (.data[] |
      [(.dt|lt(0)|.[5:10]), (.temp.max|r(0)), (.temp.min|r(0)), (.feels_like.day|r(0)),
       ((.pop // 0)*100|r(0)), (((.rain|mm) // 0)|r(1)),
       (.wind_speed|r(0)), .humidity, .clouds, (.moon_phase|moon),
       (.sunrise|lt($o)|.[11:]), (.sunset|lt($o)|.[11:]), .weather[0].description])
    | @tsv' | column -t -s $'\t'
fi
