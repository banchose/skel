# llm -f setup.py 'extract the metadata'
# llm -f - 'extract the metadata' < setup.py
#
# llm chat -f my_doc.txt

## To use bedrock with llm
# export AWS_PROFILE=test
# aws sso login --profile test
# MODEL=us.anthropic.claude-sonnet-4-5-20250929-v1
# llm --model "${MODEL}" "test"

pipx install llm
pip install strip-tags
pipx inject llm llm-tools-exa --pip-args="--upgrade" --force
pipx inject llm llm-openrouter --pip-args="--upgrade"
pipx inject llm llm-anthropic --pip-args="--upgrade" --force
pipx inject llm llm-fragments-github --pip-args="--upgrade" --force
pipx inject llm llm-tools-simpleeval --pip-args="--upgrade" --force
pipx inject llm llm-cmd-comp --pip-args="--upgrade" --force
pipx inject llm llm-cmd --pip-args="--upgrade" --force
pipx inject llm llm-templates-fabric --pip-args="--upgrade" --force
pipx inject llm llm-bedrock --pip-args="--upgrade" --force
pipx inject llm pydantic --pip-args="--upgrade" --force
pipx inject llm llm-bedrock-anthropic --pip-args="--upgrade" --force
pipx inject llm llm-fragments-github --pip-args="--upgrade" --force
pipx inject llm llm-fragments-pdf --pip-args="--upgrade" --force
pipx inject llm llm-fragments-site-text --pip-args="--upgrade" --force
pipx inject llm llm-python --pip-args="--upgrade" --force
pipx inject llm llm-jq --pip-args="--upgrade" --force
llm keys set anthropic --value "${ANTHROPIC_API_KEY}"
llm keys set exa --value "${EXA_API_KEY}"
llm models default anthropic/claude-sonnet-4-0

# -T llm_time
# echo $ANTHROPIC_API_KEY
#
# llm keys set anthropic --value "${ANTHROPIC_API_KEY}"
# llm models default anthropic/claude-sonnet-4-0
# llm keys set exa  --value "${EXA_API_KEY}" # web search
# llm keys set set openrouter --value "${OPENROUTER_API_KEY}"
# llm -m anthropic/claude-sonnet-4-0 "test, please keep response short"

## Templates

# llm --sf ~/skel/PROMPT/bash-prompt.md -m anthropic/claude-sonnet-4-0 --save bash
# llm --sf ~/gitdir/configs/PROMPT/ -m anthropic/claude-sonnet-4-0 --save aws
# llm --sf ~/aws/PROMPT/MAIN-hri-aws-prompt.txt -m anthropic/claude-sonnet-4-0 --save hriaws

# Weather example
# export LAT=42.742830
# export LON=-73.801163
# export OPENWEATHER_APP_ID="04d5441a8a0..."
# llm -s "you are a meterologist" \
# -f <(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$LAT&lon=$LON&appid=${OPENWEATHER_APP_ID}&units=metric") \
# "You will get information about the weather in the form of structured json from OpenWeatherMap.  I am in albany ny... what is the weather like?"

# set:
# export CERTBOT_DOMAIN="xaax.dev"
# export LAT=42.742830
# export LON=-73.801163
# export OPENWEATHER_LOCATION='{"lat": 42.742830, "lon": -73.801163}'
# export OPENWEATHER_APP_ID="04d5441a8a0..."
# export OPENROUTER_API_KEY="sk-or-v1-996d..."
# export OPENROUTER_KEY="sk-or-v1-996da36..."
# export ANTHROPIC_API_KEY="sk-ant-api03..."
# export PORKBUN_API_KEY="pk1_319fdfca7..."
# export PORKBUN_SECRET_KEY="sk1_22b89..."
# export WOLFRAMALPHA_API_KEY=3P72KK..."
# export JINA_API_KEY=jina_fe32f2144a..."
# export TAVILY_API_KEY=tvly-dev-mnhZ..."
# export EXTRA_openrouter_aws_service_cli="sk-or-v1-248bd21f2..."
# export EXA_API_KEY=7ba0437f-b8..."
# set:
# llm keys set openai
# llm keys set gemini
# llm keys set anthropic
# llm keys set exa  # web search

##################################################
# Example commands
##################################################
# llm -u -m anthropic/claude-sonnet-4-0 -T llm_version -T llm_time 'Give me the current time and LLM version'
#
# # Use a system prompt against a file
# cat myfile.py | llm -m anthropic/claude-sonnet-4-0 -s "Explain this code"
# llm -u -m claude-4-sonnet -T web_search "search the web to get today's weather in nyc"
#
# # Summarize a webpage
# llm -u -t fabric:summarize -f https://example.com

# Explain code from a file
# llm -u -t fabric:explain_code < script.py

# Extract wisdom from a document
# llm -u -t fabric:extract_wisdom < document.txt

# path:
# llm templates path

# https://llm.datasette.io

## Fragments

# set a fragment to a file
# llm fragments set cli cli.py
# use it
# llm -f cli 'explain this code'
#
# llm "extract text" -a scanned-document.jpg
#
# llm chat -m gpt-4.1
#
# Chatting with gpt-4.1
# Type 'exit' or 'quit' to exit
# Type '!multi' to enter multiple lines, then '!end' to finish
# Type '!edit' to open your default editor and modify the prompt.
# Type '!fragment <my_fragment> [<another_fragment> ...]' to insert one or more fragments
# > Tell me a joke about a pelican
# Why don't pelicans like to tip waiters?
#
# Because they always have a big bill!
