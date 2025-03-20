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

# Make API request for One Call API with minimal data
ONECALL_DATA=$(curl -s "https://api.openweathermap.org/data/3.0/onecall?lat=${LAT}&lon=${LON}&exclude=minutely,hourly,daily&appid=${API_KEY}&units=${UNITS}") || handle_error "API request failed"

# Extract basic weather data
TEMP_C=$(echo "${ONECALL_DATA}" | jq -r '.current.temp')
PRESSURE=$(echo "${ONECALL_DATA}" | jq -r '.current.pressure')
WEATHER_DESC=$(echo "${ONECALL_DATA}" | jq -r '.current.weather[0].description')
WEATHER_ICON=$(echo "${ONECALL_DATA}" | jq -r '.current.weather[0].icon')
CITY_NAME=$(echo "${ONECALL_DATA}" | jq -r '.timezone' | sed 's|.*/||')
DT=$(echo "${ONECALL_DATA}" | jq -r '.current.dt')
WIND_SPEED=$(echo "${ONECALL_DATA}" | jq -r '.current.wind_speed')
WIND_DEG=$(echo "${ONECALL_DATA}" | jq -r '.current.wind_deg')
WIND_GUST=$(echo "${ONECALL_DATA}" | jq -r '.current.wind_gust')
DEW_POINT_C=$(echo "${ONECALL_DATA}" | jq -r '.current.dew_point')

# Check for wind gust - use grep to be safe since it might not always be present
# WIND_GUST=$(echo "${ONECALL_DATA}" | grep -o '"wind_gust":[0-9.]*' | sed 's/"wind_gust"://' || echo "N/A")

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

# Check if dew point is a valid number
if [[ ! "${DEW_POINT_C}" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
  DEW_POINT_C="N/A"
  DEW_POINT_F="N/A"
  DEW_POINT_ICON=""
else
  # Calculate Fahrenheit from Celsius for dew point
  DEW_POINT_F=$(awk "BEGIN {printf \"%.1f\", (${DEW_POINT_C} * 9/5) + 32}")
  # Round dew point to one decimal place
  DEW_POINT_C=$(printf "%.1f" "${DEW_POINT_C}")
  DEW_POINT_F=$(printf "%.1f" "${DEW_POINT_F}")
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

# Dew point icon based on value in Fahrenheit
# Higher dew points indicate more moisture in the air and greater discomfort
get_dew_point_icon() {
  local dew_point=$1
  if [[ ! "${dew_point}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "" # No icon if invalid dew point
    return
  fi

  if (($(echo "$dew_point >= 75.0" | bc -l))); then
    echo "🥵" # Extremely uncomfortable, oppressive
  elif (($(echo "$dew_point >= 70.0" | bc -l))); then
    echo "😓" # Very humid, quite uncomfortable
  elif (($(echo "$dew_point >= 65.0" | bc -l))); then
    echo "💧" # Humid, becoming uncomfortable
  elif (($(echo "$dew_point >= 60.0" | bc -l))); then
    echo "💦" # Slightly humid, becoming noticeable
  elif (($(echo "$dew_point >= 55.0" | bc -l))); then
    echo "🌡️" # Comfortable
  elif (($(echo "$dew_point >= 50.0" | bc -l))); then
    echo "🌤️" # Very comfortable
  else
    echo "❄️" # Dry
  fi
}

# Get human-readable dew point comfort level description
get_dew_point_comfort() {
  local dew_point=$1
  if [[ ! "${dew_point}" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Unknown" # No description if invalid dew point
    return
  fi

  if (($(echo "$dew_point >= 75.0" | bc -l))); then
    echo "Extremely uncomfortable, oppressive"
  elif (($(echo "$dew_point >= 70.0" | bc -l))); then
    echo "Very humid and uncomfortable"
  elif (($(echo "$dew_point >= 65.0" | bc -l))); then
    echo "Humid, becoming uncomfortable"
  elif (($(echo "$dew_point >= 60.0" | bc -l))); then
    echo "Slightly humid, becoming noticeable"
  elif (($(echo "$dew_point >= 55.0" | bc -l))); then
    echo "Comfortable"
  elif (($(echo "$dew_point >= 50.0" | bc -l))); then
    echo "Very comfortable"
  else
    echo "Dry air"
  fi
}

WEATHER_ICON=$(get_icon "${WEATHER_ICON}")
WIND_ICON=$(get_wind_icon "${ICON_SPEED}")

# Get dew point icon and comfort level if dew point is available
if [[ "${DEW_POINT_F}" != "N/A" ]]; then
  DEW_POINT_ICON=$(get_dew_point_icon "${DEW_POINT_F}")
  DEW_POINT_COMFORT=$(get_dew_point_comfort "${DEW_POINT_F}")
  DEW_POINT_DISPLAY=" ${DEW_POINT_ICON} ${DEW_POINT_F}°F"
else
  DEW_POINT_DISPLAY=""
  DEW_POINT_COMFORT="Unknown"
fi

# Create JSON output with weather icon, wind icon, gust info, and dew point in the main text
echo "{\"text\":\"${TEMP_C}°C / ${TEMP_F}°F ${WEATHER_ICON} ${WIND_ICON}${GUST_DISPLAY}${DEW_POINT_DISPLAY}${ALERT_ICON}\", \"tooltip\":\"${CITY_NAME}: ${WEATHER_DESC}\nPressure: ${PRESSURE}\nWind: ${WIND_SPEED_MPH} mph ${WIND_DIR}\nGust: ${WIND_GUST_MPH} mph\nDew Point: ${DEW_POINT_F}°F (${DEW_POINT_C}°C)\nHumidity Feel: ${DEW_POINT_COMFORT}\nData time: ${DATA_TIME}${ALERT_TEXT}\", \"class\":\"weather\"}"
