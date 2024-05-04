#!/bin/bash

KeyFile=~/sec/perplexity_key.env
AUTH_TOKEN=""
MODEL="sonar-medium-online"
QUESTION="$1"
LOG=~/temp/perplexity_ai.log
DATA='
  {
    "model": "'"$MODEL"'",
    "messages": [
      {
        "role": "system",
        "content": "Favor precise and concise. The current date and time in your location (Albany, NY) is: '"$(date)"'"
      },
      {
        "role": "user",
        "content": "'" $QUESTION"'"
      }
    ]
  }
  '

tell() {
	# Ensure the first argument is provided
	if [ -z "$1" ]; then
		echo "Usage: $0 'Your question here'"
		return 1
	fi

	[[ -r $KeyFile ]] || {
		echo "Can't read $KeyFile"
		return 0
	}

	source "$KeyFile"

	# Use the variable in the data payload
	curl -s --request POST \
		--url https://api.perplexity.ai/chat/completions \
		--header "accept: application/json" \
		--header "authorization: Bearer $Perplexity_api_key" \
		--header "content-type: application/json" \
		--data "$DATA" | jq '.choices[0].message.content' | sed -e 's/\"//g' -e 's/\\n/\n/g' | fmt
	{
		echo 'Previous answer: '
		date '+%D %H:%M:%S'
		echo '#'
		echo '#'
	} >>"$LOG"
}

# --data "$DATA" | jq '.choices[0].message.content' | sed -e 's/\"//g' -e 's/\\n/\n/g' | tee --append "$LOG" | fmt
