get_weather() {
  # Ensure required environment variables are set
  if [[ -z "$OPENWEATHER_APP_ID" ]]; then
    echo "❌ Error: OPENWEATHER_APP_ID is not set." >&2
    return 1
  fi

  if [[ -z "$OPENWEATHER_LOCATION" ]]; then
    echo "❌ Error: OPENWEATHER_LOCATION is not set." >&2
    return 1
  fi

  # Extract latitude and longitude
  LAT=$(echo "$OPENWEATHER_LOCATION" | jq -r '.lat')
  LON=$(echo "$OPENWEATHER_LOCATION" | jq -r '.lon')

  # Validate extracted values
  if [[ -z "$LAT" || -z "$LON" || "$LAT" == "null" || "$LON" == "null" ]]; then
    echo "❌ Error: Invalid OPENWEATHER_LOCATION format. Expected JSON: {\"lat\": xx.x, \"lon\": xx.x}" >&2
    return 1
  fi

  # Fetch weather data from OpenWeather API
  RESPONSE=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=${OPENWEATHER_APP_ID}&units=metric")

  # Validate API response
  if echo "$RESPONSE" | jq -e '.cod == 200' >/dev/null; then
    echo "$RESPONSE" | jq '{
            location: .name,
            weather: .weather[0].main,
            description: .weather[0].description,
            temperature: .main.temp,
            wind_speed: .wind.speed,
            humidity: .main.humidity,
            pressure: .main.pressure,
            feels_like: .main.feels_like,
            temp_min: .main.temp_min,
            temp_max: .main.temp_max,
            wind_direction: .wind.deg,
            weather_time: (.dt | todate),
            sunrise: (.sys.sunrise | todate),
            sunset: (.sys.sunset | todate)
        }'
  else
    echo "❌ Error: Failed to retrieve weather data. API Response: $(echo "$RESPONSE" | jq -r '.message')" >&2
    return 1
  fi
}
