#!/usr/bin/env bash

getwet() {
  # Ensure required environment variables are set
  if [[ -z "${OPENWEATHER_APP_ID}" ]]; then
    echo "❌ Error: OPENWEATHER_APP_ID is not set." >&2
    return 1
  fi

  if [[ -z "${OPENWEATHER_LOCATION}" ]]; then
    echo "❌ Error: OPENWEATHER_LOCATION is not set." >&2
    return 1
  fi

  # Extract latitude and longitude
  LAT=$(echo "${OPENWEATHER_LOCATION}" | jq -r '.lat')
  LON=$(echo "${OPENWEATHER_LOCATION}" | jq -r '.lon')

  # Validate extracted values
  if [[ -z "${LAT}" || -z "${LON}" || "${LAT}" == "null" || "${LON}" == "null" ]]; then
    echo "❌ Error: Invalid OPENWEATHER_LOCATION format. Expected JSON: {\"lat\": xx.x, \"lon\": xx.x}" >&2
    return 1
  fi

  # Fetch weather data from OpenWeather OneCall API 3.0
  # Exclude all but current data
  RESPONSE=$(curl -s -f "https://api.openweathermap.org/data/3.0/onecall?lat=${LAT}&lon=${LON}&exclude=minutely,hourly,daily,alerts&appid=${OPENWEATHER_APP_ID}&units=metric")

  # Check if curl command failed
  if [[ $? -ne 0 ]]; then
    echo "❌ Error: Failed to connect to OpenWeather API. Check your internet connection or API endpoint." >&2
    return 1
  fi

  # Check if the response is valid JSON
  if ! echo "${RESPONSE}" | jq empty &>/dev/null; then
    echo "❌ Error: Invalid JSON response from API." >&2
    echo "Response: ${RESPONSE}" >&2
    return 1
  fi

  # Check for API error messages
  if echo "${RESPONSE}" | jq -e 'has("cod") and (.cod | tostring | startswith("4") or startswith("5"))' &>/dev/null; then
    ERROR_MSG=$(echo "${RESPONSE}" | jq -r '.message // "Unknown error"')
    ERROR_CODE=$(echo "${RESPONSE}" | jq -r '.cod')
    echo "❌ Error: API returned error code ${ERROR_CODE}: ${ERROR_MSG}" >&2
    return 1
  fi

  # Validate expected data structure exists
  if ! echo "${RESPONSE}" | jq -e 'has("current")' &>/dev/null; then
    echo "❌ Error: Response does not contain current weather data." >&2
    echo "Response: $(echo "${RESPONSE}" | jq -c '.')" >&2
    return 1
  fi

  # Everything looks good, process the data
  echo "${RESPONSE}" | jq '{
    location: .timezone,
    weather: .current.weather[0].main,
    description: .current.weather[0].description,
    temperature: .current.temp,
    feels_like: .current.feels_like,
    humidity: .current.humidity,
    pressure: .current.pressure,
    wind_speed: .current.wind_speed,
    wind_direction: .current.wind_deg,
    wind_gust: .current.wind_gust,
    weather_time: (.current.dt | todate),
    sunrise: (.current.sunrise | todate),
    sunset: (.current.sunset | todate),
    uvi: .current.uvi,
    visibility: .current.visibility,
    clouds: .current.clouds
  }'

  return 0
}
