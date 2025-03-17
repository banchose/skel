#!/usr/bin/env bash
set -euo pipefail

# For debugging - save both stderr and full API response
exec 2>>/tmp/waybar-weather-error.log

# Function to handle errors
handle_error() {
  echo "{\"text\":\"Weather Unavailable ⚠️\", \"tooltip\":\"Error: ${1}\"}"
  echo "Error: ${1}" >>/tmp/waybar-weather-error.log
  exit 1
}

# Get API key from environment variable
if [[ -z "${OPENWEATHER_APP_ID:-}" ]]; then
  handle_error "API key (OPENWEATHER_APP_ID) is not set"
fi
API_KEY="${OPENWEATHER_APP_ID}"

# Get location from environment variable
if [[ -z "${OPENWEATHER_LOCATION:-}" ]]; then
  handle_error "Location (OPENWEATHER_LOCATION) is not set"
fi

# Parse latitude and longitude from OPENWEATHER_LOCATION
LAT=$(echo "${OPENWEATHER_LOCATION}" | jq -r '.lat') || handle_error "Failed to parse latitude"
LON=$(echo "${OPENWEATHER_LOCATION}" | jq -r '.lon') || handle_error "Failed to parse longitude"

# Verify latitude and longitude
if [[ ! "${LAT}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] || [[ ! "${LON}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
  handle_error "Invalid latitude or longitude in OPENWEATHER_LOCATION"
fi

# Units setting
UNITS="metric" # Use metric for Celsius as the base

# Make API request for One Call API and save full response
ONECALL_RESPONSE=$(curl -s "https://api.openweathermap.org/data/3.0/onecall?lat=${LAT}&lon=${LON}&exclude=minutely&appid=${API_KEY}&units=${UNITS}")
echo "FULL API RESPONSE: ${ONECALL_RESPONSE}" >/tmp/waybar-weather-full-response.json

# Parse the data
ONECALL_DATA=$(echo "${ONECALL_RESPONSE}") || handle_error "Failed to parse API response"

# Extract data using grep and sed (alternative to jq)
echo "Checking for wind gust in raw JSON..." >>/tmp/waybar-weather-debug.log
grep -o '"wind_gust":[0-9.]*' /tmp/waybar-weather-full-response.json >>/tmp/waybar-weather-debug.log

# Now use jq for extraction
TEMP_C=$(echo "${ONECALL_DATA}" | jq -r '.current.temp')
PRESSURE=$(echo "${ONECALL_DATA}" | jq -r '.current.pressure')
WEATHER_DESC=$(echo "${ONECALL_DATA}" | jq -r '.current.weather[0].description')
WEATHER_ICON=$(echo "${ONECALL_DATA}" | jq -r '.current.weather[0].icon')
CITY_NAME=$(echo "${ONECALL_DATA}" | jq -r '.timezone' | sed 's|.*/||')
DT=$(echo "${ONECALL_DATA}" | jq -r '.current.dt')
WIND_SPEED=$(echo "${ONECALL_DATA}" | jq -r '.current.wind_speed')
WIND_DEG=$(echo "${ONECALL_DATA}" | jq -r '.current.wind_deg')

# Try multiple ways to extract wind gust
WIND_GUST_RAW=$(echo "${ONECALL_DATA}" | jq '.current.wind_gust')
echo "WIND_GUST_RAW (jq output): ${WIND_GUST_RAW}" >>/tmp/waybar-weather-debug.log

# Manual extraction for wind_gust
WIND_GUST_GREP=$(grep -o '"wind_gust":[0-9.]*' /tmp/waybar-weather-full-response.json | head -1 | sed 's/"wind_gust"://')
echo "WIND_GUST_GREP (grep output): ${WIND_GUST_GREP}" >>/tmp/waybar-weather-debug.log

# Use the grep result if available, otherwise fall back to N/A
if [[ -n "${WIND_GUST_GREP}" ]]; then
  WIND_GUST="${WIND_GUST_GREP}"
elif [[ "${WIND_GUST_RAW}" != "null" && -n "${WIND_GUST_RAW}" ]]; then
  WIND_GUST="${WIND_GUST_RAW}"
else
  WIND_GUST="N/A"
fi

echo "Final WIND_GUST value: ${WIND_GUST}" >>/tmp/waybar-weather-debug.log

# Extract weather alert information
ALERT_ICON=""
ALERT_TEXT=""
if echo "${ONECALL_DATA}" | jq -e '.alerts' >/dev/null; then
  ALERT_COUNT=$(echo "${ONECALL_DATA}" | jq '.alerts | length')
  if [ "${ALERT_COUNT}" -gt 0 ]; then
    ALERT_ICON=" !" # More muted alert icon
    FIRST_ALERT=$(echo "${ONECALL_DATA}" | jq -r '.alerts[0].event')
    ALERT_TEXT="\nALERT: ${FIRST_ALERT}"
    if [ "${ALERT_COUNT}" -gt 1 ]; then
      ALERT_TEXT="${ALERT_TEXT} (and ${ALERT_COUNT-1} more)"
    fi
  fi
fi

# Format the time in 24-hour format (HH:MM)
if [[ -n "${DT}" && "${DT}" != "null" ]]; then
  DATA_TIME=$(date -d "@${DT}" "+%H:%M")
else
  DATA_TIME="unknown"
fi

# Convert wind speeds to mph (from m/s)
if [[ "${WIND_SPEED}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  WIND_SPEED_MPH=$(awk "BEGIN {printf \"%.1f\", ${WIND_SPEED} * 2.237}")
else
  WIND_SPEED_MPH="N/A"
fi

if [[ "${WIND_GUST}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  WIND_GUST_MPH=$(awk "BEGIN {printf \"%.1f\", ${WIND_GUST} * 2.237}")
  GUST_DISPLAY=" ${WIND_GUST_MPH}"
else
  WIND_GUST_MPH="N/A"
  GUST_DISPLAY=""
fi

# Debug the conversion
echo "After conversion: WIND_SPEED_MPH=${WIND_SPEED_MPH}, WIND_GUST_MPH=${WIND_GUST_MPH}" >>/tmp/waybar-weather-debug.log

# Determine the speed to use for the wind icon (use gust if available, otherwise use wind speed)
if [[ "${WIND_GUST}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  ICON_SPEED="${WIND_GUST_MPH}" # Use gust for icon if available
else
  ICON_SPEED="${WIND_SPEED_MPH}" # Fallback to wind speed
fi

# Get wind direction as a compass point
get_wind_direction() {
  local degrees=$1
  local directions=("N" "NNE" "NE" "ENE" "E" "ESE" "SE" "SSE" "S" "SSW" "SW" "WSW" "W" "WNW" "NW" "NNW" "N")
  local index=$(awk "BEGIN {printf \"%d\", (${degrees} + 11.25) / 22.5}")
  echo "${directions[index]}"
}

WIND_DIR=$(get_wind_direction "${WIND_DEG}")

# Check if temperature is a valid number
if [[ ! "${TEMP_C}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
  handle_error "Invalid temperature value"
fi

# Check if pressure is a valid number
if [[ ! "${PRESSURE}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  PRESSURE="N/A"
else
  # Convert hPa to inHg (inches of mercury) for those who prefer imperial units
  PRESSURE_INHG=$(awk "BEGIN {printf \"%.2f\", ${PRESSURE} * 0.02953}")
  PRESSURE="${PRESSURE} hPa / ${PRESSURE_INHG} inHg"
fi

# Calculate Fahrenheit from Celsius
TEMP_F=$(awk "BEGIN {printf \"%.1f\", (${TEMP_C} * 9/5) + 32}")

# Round temperature to one decimal place
TEMP_C=$(printf "%.1f" "${TEMP_C}")

# Select icon based on weather condition code
get_icon() {
  local icon_code="${1}"
  case "${icon_code:0:2}" in
  "01") echo "☀️" ;; # clear sky
  "02") echo "🌤️" ;; # few clouds
  "03") echo "☁️" ;; # scattered clouds
  "04") echo "☁️" ;; # broken clouds
  "09") echo "🌧️" ;; # shower rain
  "10") echo "🌦️" ;; # rain
  "11") echo "⛈️" ;; # thunderstorm
  "13") echo "❄️" ;; # snow
  "50") echo "🌫️" ;; # mist
  *) echo "🌡️" ;;    # default
  esac
}

# Wind icon based on speed in mph
get_wind_icon() {
  local speed=$1
  if [[ ! "${speed}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "" # No icon if invalid speed
    return
  fi

  if (($(echo "$speed > 38.0" | bc -l))); then   # Hurricane/storm force
    echo "🌪️"                                    # hurricane
  elif (($(echo "$speed > 30.0" | bc -l))); then # Gale/near gale
    echo "💨"                                     # strong wind
  elif (($(echo "$speed > 12.0" | bc -l))); then # Moderate breeze
    echo "🍃"                                     # moderate wind
  elif (($(echo "$speed > 5.0" | bc -l))); then  # Light breeze
    echo "🌬️"                                    # light wind
  else
    echo "🌫️" # very light/calm
  fi
}

WEATHER_ICON=$(get_icon "${WEATHER_ICON}")
WIND_ICON=$(get_wind_icon "${ICON_SPEED}")

# Check our final values before output
echo "Final values - WEATHER_ICON: ${WEATHER_ICON}, WIND_ICON: ${WIND_ICON}, GUST_DISPLAY: ${GUST_DISPLAY}" >>/tmp/waybar-weather-debug.log

# Create JSON output with weather icon, wind icon and gust info in the main text
echo "{\"text\":\"${TEMP_C}°C / ${TEMP_F}°F ${WEATHER_ICON} ${WIND_ICON}${GUST_DISPLAY}${ALERT_ICON}\", \"tooltip\":\"${CITY_NAME}: ${WEATHER_DESC}\nPressure: ${PRESSURE}\nWind: ${WIND_SPEED_MPH} mph ${WIND_DIR}\nGust: ${WIND_GUST_MPH} mph\nData time: ${DATA_TIME}${ALERT_TEXT}\", \"class\":\"weather\"}"
