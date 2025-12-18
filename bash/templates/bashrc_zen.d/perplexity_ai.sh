#!/bin/bash

tell() {
	# Ensure the first argument is provided
	if [ -z "$1" ]; then
		echo "Usage: $0 'Your question here'"
		return 1
	fi

	# Replace 'abc' with your actual authorization token
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
        "content": "Favor precise and concise. Your location is the state of New York in the USA. You are in the Eastern Standard time zone. The current date and time here is: '"$(date)"'"
      },
      {
        "role": "user",
        "content": "'" $QUESTION"'"
      }
    ]
  }
  '
	# Use the variable in the data payload
	curl -s --request POST \
		--url https://api.perplexity.ai/chat/completions \
		--header "accept: application/json" \
		--header "authorization: Bearer $AUTH_TOKEN" \
		--header "content-type: application/json" \
		--data "$DATA" | jq '.choices[0].message.content' | sed -e 's/\"//g' -e 's/\\n/\n/g' | tee --append "$LOG" | fmt
	{
		echo 'Previous answer: '
		date '+%D %H:%M:%S'
		echo '#'
		echo '#'
	} >>"$LOG"
}
