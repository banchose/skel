#!/bin/bash

KeyFile=~/sec/perplexity_key.env
# MODEL="llama-3-sonar-large-32k-online"
MODEL="llama-3-sonar-small-32k-online"

tell() {
	# Ensure the first argument is provided
	if [ -z "$1" ]; then
		echo "Usage: tell 'Your question here'"
		return 1
	fi

	source "${KeyFile}"

	QUESTION="$1"

	[[ -r $KeyFile ]] || {
		echo "Can't read $KeyFile"
		return 0
	}

	DATA='
    {
      "model": "'"$MODEL"'",
      "messages": [
        {
          "role": "system",
          "content": "You will favor precise and concise. You are located in the New York State Capital District Albany New York 12204. Current date/time is: '"$(date)"'"
        },
        {
          "role": "user",
          "content": "'"$QUESTION"'"
        }
      ]
    }
    '
	# Use the variable in the data payload
	curl -s --request POST \
		--url https://api.perplexity.ai/chat/completions \
		--header "accept: application/json" \
		--header "authorization: Bearer $Perplexity_api_key" \
		--header "content-type: application/json" \
		--data "$DATA" | jq '.choices[0].message.content' | sed -e 's/\"//g' -e 's/\\n/\n/g' | fmt

}
# --data "$DATA" | jq '.choices[0].message.content' | sed -e 's/\"//g' -e 's/\\n/\n/g' | tee --append "$LOG" | fmt
# [4563][arc][una][2024-05-18 22:03:53][~/gitdir/configs]
# [0][5.2]$ curl -s --request POST --url https://api.perplexity.ai/chat/completions --header "accept: application/json" --header "authorization: Bearer $Perplexity_api_key" --header "content-type: application/json" --data "hello"
# {"error":{"message":"[\"At body -> 0: JSON decode error\"]","type":"bad_request","code":400}}[4564][arc][una][2024-05-18 22:04:19][~/gitdir/configs]
# [0][5.2]$ curl -s --request POST --url https://api.perplexity.ai/chat/completions --header "accept: application/json" --header "authorization: Bearer $Perplexity_api_key" --header "content-type: application/json" --data '{"prompt": "hello"}'
# {"error":{"message":"[\"At body -> model: Field required\", \"At body -> messages: Field required\"]","type":"bad_request","code":400}}[4565][arc][una][2024-05-18 22:08:40][~/gitdir/configs]
# [0][5.2]$ curl -s --request POST --url https://api.perplexity.ai/chat/completions --header "accept: application/json" --header "authorization: Bearer $Perplexity_api_key" --header "content-type: application/json" --data '{"prompt": "hello"}'
# {"error":{"message":"[\"At body -> model: Field required\", \"At body -> messages: Field required\"]","type":"bad_request","code":400}}[4565][arc][una][2024-05-18 22:08:58][~/gitdir/configs]
#
