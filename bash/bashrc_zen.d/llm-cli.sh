# Check for required environment variables
[[ -z $ANTHROPIC_API_KEY ]] && echo "***** ANTHROPIC_API_KEY not set *****" >&2
[[ -z $AWS_BEARER_TOKEN_BEDROCK ]] && echo "***** AWS_BEARER_TOKEN_BEDROCK not set *****" >&2
[[ -z $AWS_BEDROCK_DEFAULT_MODEL ]] && echo "***** AWS_BEDROCK_DEFAULT_MODEL is not set *****" >&2

# AWS Bedrock
alias llmtestbed='llm "This is just a test. Please respond with a short acknowledgement" -m "${AWS_BEDROCK_DEFAULT_MODEL}"'

llm-test-bedrock() {

  echo "checking llm default model"
  llm models default
  echo "AWS_BEARER_TOKEN_BEDROCK is set to ${AWS_BEARER_TOKEN_BEDROCK:0:8}"
  echo "AWS_BEDROCK_DEFAULT_MODEL is set to ${AWS_BEDROCK_DEFAULT_MODEL}"
  llm "This is just a test. Please respond with a short acknowledgement" -m "${AWS_BEDROCK_DEFAULT_MODEL}"

}

# Use a function instead of alias to capture date once
llmbed() {
  local current_date
  current_date=$(date)
  llm -s "It is currently ${current_date}. Please be accurate and concise." -m "${AWS_BEDROCK_DEFAULT_MODEL}" "$@"
}

llm-set-bedrock() {
  if [[ -z "${AWS_BEARER_TOKEN_BEDROCK+x}" ]]; then
    printf 'WARNING: AWS_BEARER_TOKEN_BEDROCK is not set\n' >&2
    return 1
  fi

  local token="${AWS_BEARER_TOKEN_BEDROCK}"
  local len="${#token}"

  if ((len > 16)); then
    printf 'AWS_BEARER_TOKEN_BEDROCK: %s…%s (len=%d)\n' \
      "${token:0:8}" "${token: -8}" "${len}" >&2
  else
    printf 'AWS_BEARER_TOKEN_BEDROCK: [token too short to truncate] (len=%d)\n' \
      "${len}" >&2
  fi

  llm models default "${AWS_BEDROCK_DEFAULT_MODEL}"
}

# DRY principle - extract common weather function
_llm_weather_common() {
  local mode="$1" # "chat" or regular
  local current_date
  current_date=$(date)

  local weather_url="https://api.open-meteo.com/v1/forecast"
  weather_url+="?latitude=42.742830&longitude=-73.801163"
  weather_url+="&current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,weather_code,cloud_cover,visibility"
  weather_url+="&hourly=temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m,precipitation,precipitation_probability,rain,showers,snowfall,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,visibility,cape"
  weather_url+="&daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant"
  weather_url+="&past_days=2&forecast_days=3&timezone=America/New_York"

  local system_prompt="You are a very experienced and cool Weatherman. You have an aged style and grace. You specialize in using your vast knowledge and experience providing weather insights from patterns in the data that some weatherman might miss. You specialize in predicting hazardous conditions for the general Albany, NY area either current or near future. The current date is ${current_date}. Please indicate the current date as given and indicate the date of the forecast as provided in the json weather information. I want you to be working with only the most up to date information and to be aware when you are not. I would like you to first give the detailed current conditions including dew point. Then provide a section for future forecast, and last a section on alerts or notable conditions."

  if [[ "$mode" == "chat" ]]; then
    curl -s "$weather_url" |
      llm chat -s "$system_prompt" -o temperature 0.6
  else
    curl -s "$weather_url" |
      llm -s "$system_prompt" -o temperature 0.6
  fi
}

llmwet() {
  _llm_weather_common "regular"
}

llmwetc() {
  _llm_weather_common "chat"
}
