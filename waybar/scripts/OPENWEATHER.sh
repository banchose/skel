#!/usr/bin/env bash
set -euo pipefail

# Function to handle errors
handle_error() {
  echo "{\"text\":\"Weather Unavailable ⚠️\", \"tooltip\":\"Error: ${1}\"}"
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

# Make API request
WEATHER_DATA=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=${LAT}&lon=${LON}&appid=${API_KEY}&units=${UNITS}") || handle_error "API request failed"

# Check if the API returned an error
if echo "${WEATHER_DATA}" | jq -e '.cod != 200' >/dev/null; then
  ERROR_MSG=$(echo "${WEATHER_DATA}" | jq -r '.message // "Unknown error"')
  handle_error "API error: ${ERROR_MSG}"
fi

# Extract the dt (data calculation time) from the API response and format it in 24-hour format
DT=$(echo "${WEATHER_DATA}" | jq -r '.dt')
if [[ -n "${DT}" && "${DT}" != "null" ]]; then
  # Format the time in 24-hour format (HH:MM)
  DATA_TIME=$(date -d "@${DT}" "+%H:%M")
else
  DATA_TIME="unknown"
fi

# Extract temperature (in Celsius), pressure and other relevant data
TEMP_C=$(echo "${WEATHER_DATA}" | jq -r '.main.temp')
PRESSURE=$(echo "${WEATHER_DATA}" | jq -r '.main.pressure')
WEATHER_DESC=$(echo "${WEATHER_DATA}" | jq -r '.weather[0].description')
WEATHER_ICON=$(echo "${WEATHER_DATA}" | jq -r '.weather[0].icon')
CITY_NAME=$(echo "${WEATHER_DATA}" | jq -r '.name')

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

ICON=$(get_icon "${WEATHER_ICON}")

# Create JSON output for Waybar with the actual data time in 24-hour format
echo "{\"text\":\"${TEMP_C}°C / ${TEMP_F}°F ${ICON}\", \"tooltip\":\"${CITY_NAME}: ${WEATHER_DESC}\nPressure: ${PRESSURE}\nData time: ${DATA_TIME}\", \"class\":\"weather\"}"
