alias llm='llm -s "Please be acurate and concise. Please note the current date before answering the question" -u -m anthropic/claude-sonnet-4-0 -T web_search -T llm_time -T simple_eval'
alias llmo='llm -s "Please be acurate and concise. Please note the current date before answering the question" -u -m anthropic/claude-opus-4-0 -T web_search -T simple_eval -T llm_time'

llmwet() {
  curl -s "https://api.open-meteo.com/v1/forecast?\
latitude=42.742830&longitude=-73.801163&\
current=temperature_2m,relative_humidity_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,weather_code,cloud_cover,visibility&\
hourly=temperature_2m,apparent_temperature,relative_humidity_2m,dew_point_2m,precipitation,precipitation_probability,rain,showers,snowfall,weather_code,cloud_cover,wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,visibility,cape&\
daily=weather_code,temperature_2m_max,temperature_2m_min,apparent_temperature_max,precipitation_sum,precipitation_probability_max,wind_speed_10m_max,wind_gusts_10m_max,wind_direction_10m_dominant&\
past_days=2&forecast_days=3&timezone=America/New_York" |
    \llm -s "You are an old and very wise Weatherman. \
  You specialize in predicting hazardous conditions for the general Albany, NY \
  area either current or near future. \
  I would like you to first give the detailed current contions including dew point. \
  Then provide a section for future forcast, and last a section on alerts or notable conditions" \
      -o temperature 0.2
}

# pipx install llm
# pipx inject llm llm-tools-exa --pip-args="--upgrade" --force
# pipx inject llm llm-openrouter --pip-args="--upgrade"
# pipx inject llm llm-anthropic --pip-args="--upgrade" --force
# pipx inject llm llm-fragments-github --pip-args="--upgrade" --force
# pipx inject llm llm-tools-simpleeval --pip-args="--upgrade" --force
# pipx inject llm llm-cmd-comp --pip-args="--upgrade" --force
# pipx inject llm llm-cmd --pip-args="--upgrade" --force
# pipx inject llm llm-templates-fabric --pip-args="--upgrade" --force

# set:
# export OPENWEATHER_APP_ID="04d5441a8a0215
# export OPENWEATHER_LOCATION='{"lat": 42.742830, "lon": -73.801163}'
# export LAT=42.742830
# export LON=-73.801163
# export OPENROUTER_API_KEY="sk-or-v1-996d
# export OPENROUTER_KEY="sk-or-v1-996da36
# export ANTHROPIC_API_KEY="sk-ant-api03
# export PORKBUN_API_KEY="pk1_319fdfca7
# export PORKBUN_SECRET_KEY="sk1_22b89
# export CERTBOT_DOMAIN="xaax.dev"
# export WOLFRAMALPHA_API_KEY=3P72KK-
# export JINA_API_KEY=jina_fe32f2144a
# export TAVILY_API_KEY=tvly-dev-mnhZ
# export EXTRA_openrouter_aws_service_cli="sk-or-v1-248bd21f2
# export EXA_API_KEY=7ba0437f-b8
# set:
# llm keys set openai
# llm keys set gemini
# llm keys set anthropic
# llm keys set exa  # web search

##################################################
# Example commands
##################################################
# llm -m claude-4-sonnet -T web_search "search the web to get today's weather in nyc"
#
# # Summarize a webpage
# llm -t fabric:summarize -f https://example.com

# Explain code from a file
# llm -t fabric:explain_code < script.py
# llm -t fabric:create_flash_cards
# Extract wisdom from a document
# llm -t fabric:extract_wisdom < document.txt

# https://llm.datasette.io
