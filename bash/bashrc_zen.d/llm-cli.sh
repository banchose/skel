# export export LLM_MODEL=gpt-4.1-mini

# Check for required environment variables
[[ -z $ANTHROPIC_API_KEY ]] && echo "***** ANTHROPIC_API_KEY not set *****" >&2
[[ -z $OPENROUTER_API_KEY ]] && echo "***** OPENROUTER_API_KEY not set *****" >&2
[[ -z $AWS_BEARER_TOKEN_BEDROCK ]] && echo "***** AWS_BEARER_TOKEN_BEDROCK not set *****" >&2
[[ -z $AWS_BEDROCK_DEFAULT_MODEL ]] && echo "***** AWS_BEDROCK_DEFAULT_MODEL is not set *****" >&2

export OPENROUTER_DEFAULT_MODEL=openrouter/anthropic/claude-sonnet-4.6
echo "EXPORTING OPENROUTER_DEFAULT_MODEL: ${OPENROUTER_DEFAULT_MODEL}"

# AWS Bedrock
# alias llm-test-bedrock='llm "This is just a test. Please respond with a short acknowledgement" -m "${AWS_BEDROCK_DEFAULT_MODEL}"'
alias llm_png='wl-paste | llm --at - image/png'
alias llm_or_srch='llm -m "${OPENROUTER_DEFAULT_MODEL}" -o online 1'

llm_set_openrouter_key() {

  llm keys set openrouter --value "${OPENROUTER_API_KEY}"

}

llm_test_bedrrock() {

  echo "checking llm default model"
  echo "----"
  llm models default
  echo "----"
  echo "llm cli keys are located:"
  echo "----"
  llm keys path
  echo "----"
  echo "llm cli keys set:"
  echo "----"
  llm keys
  echo "----"
  echo "AWS_BEARER_TOKEN_BEDROCK is set to ${AWS_BEARER_TOKEN_BEDROCK:0:8}"
  echo "AWS_BEDROCK_DEFAULT_MODEL is set to ${AWS_BEDROCK_DEFAULT_MODEL}"
  echo "----"
  llm "This is just a test. Please respond with a short acknowledgement" -m "${AWS_BEDROCK_DEFAULT_MODEL}"

}

llm_help() {

  echo "llm keys list"
  echo "llm keys path"
  echo "llm keys get"
  echo "llm keys set"
  echo "llm logs status"
  echo "llm logs on/off/list"
  echo "llm models options"
  echo "llm models list"
  echo "llm models default # show the default model"
  echo "llm models default MODEL # to set default model"
  echo "llm -c # to continue chat"
  echo "llm prompt --help"
  echo 'cat ml_script.py | llm "Walk through this file and explain how it works. Start with a summary, then go line-by-line for the most difficult sections."'
  echo "find . -name '*.py' | xargs -I {} sh -c 'echo \"\n=== {} ===\n\"; cat {}'"
  echo "find . -name '*.py' | xargs -I {} sh -c 'echo \"\n=== {} ===\n\"; cat {}' | llm \"Explain this project and summarize the key components.\""

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
