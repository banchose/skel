curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$(echo $OPENWEATHER_LOCATION | jq -r '.lat')&lon=$(echo $OPENWEATHER_LOCATION | jq -r '.lon')&appid=${OPENWEATHER_APP_ID}&units=metric" | jq '{
  weather_time: (.dt | todate),
  sunrise: (.sys.sunrise | todate),
  sunset: (.sys.sunset | todate)
}'
