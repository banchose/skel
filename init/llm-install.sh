# llm -f setup.py 'extract the metadata'
# llm -f - 'extract the metadata' < setup.py
#
# llm chat -f my_doc.txt

pipx install llm
pipx inject llm llm-tools-exa --pip-args="--upgrade" --force
pipx inject llm llm-openrouter --pip-args="--upgrade"
pipx inject llm llm-anthropic --pip-args="--upgrade" --force
pipx inject llm llm-fragments-github --pip-args="--upgrade" --force
pipx inject llm llm-tools-simpleeval --pip-args="--upgrade" --force
pipx inject llm llm-cmd-comp --pip-args="--upgrade" --force
pipx inject llm llm-cmd --pip-args="--upgrade" --force
pipx inject llm llm-python --pip-args="--upgrade" --force
pipx inject llm llm-jq --pip-args="--upgrade" --force
pipx inject llm llm-templates-fabric --pip-args="--upgrade" --force
# pipx inject ipython ipython-extensions --pip-args="--upgrade" --force
# pipx inject ipython ipython-sql --pip-args="--upgrade" --force

# create HRI and bash templates
# llm --sf ~/skel/PROMPT/bash-prompt.md -m anthropic/claude-sonnet-4-0 --save bash
# llm --sf ~/aws/PROMPT/MAIN-hri-aws-prompt.txt -m anthropic/claude-sonnet-4-0 --save hriaws

# llm --system 'You are a sentient cheesecake' -m gpt-4 --save cheesecake
# llm -m 'anthropic/claude-sonnet-4-0' -s 'You are a sentient cheesecake' hello --save cheesecake
# llm -m 'anthropic/claude-sonnet-4-0' -s 'You are a sentient cheesecake'  --save cheesecake
# llm --schema dog.schema.json 'invent a dog' --save dog
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
# llm -m anthropic/claude-sonnet-4-0 -T llm_version -T llm_time 'Give me the current time and LLM version'
#
# # Use a system prompt against a file
# cat myfile.py | llm -m anthropic/claude-sonnet-4-0 -s "Explain this code"
# llm -m claude-4-sonnet -T web_search "search the web to get today's weather in nyc"
#
# # Summarize a webpage
# llm -t fabric:summarize -f https://example.com

# Explain code from a file
# llm -t fabric:explain_code < script.py

# Extract wisdom from a document
# llm -t fabric:extract_wisdom < document.txt

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
#
#
