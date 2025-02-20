source ~/.bashrc_zen.d/api_keys_envs.sh
# 0. Import Api keys
# 1. EndPoint
# 2. Model
# 3. Max tokens
# 4. Token key
#
# Endpoint
#
OR_ENDPOINT="https://openrouter.ai/api/v1/chat/completions"
Current_Endpoint="${OR_ENDPOINT}"

# Models
#
#
## OpenRouter
#
# OR_MODEL="mistralai/mistral-nemo"
# OR_MODEL="deepseek/deepseek-chat"
# OR_MODEL="anthropic/claude-3.5-sonnet"
# OR_MODEL="meta-llama/llama-3.3-70b-instruct"
OR_MODEL="anthropic/claude-3.5-haiku"
# OR_MODE="anthropic/claude-3.5-sonnet"
# OR_MODEL="anthropic/claude-3.5-sonnet"
# OR_MODEL="mistralai/mistral-large-2411"
# OR_MODEL="minimax/minimax-01"
# OR_MODEL="deepseek/deepseek-r1"
# OR_MODEL="anthropic/claude-3-opus"

Current_Model="${OR_MODEL}"

#
# Tokens
#
Max_Input_Tokens=2048
Max_Tokens=2048
#
# API Key
#
API_KEY="${OPENROUTER_API_KEY}"
# echo "${OPENROUTER_API_KEY}"
# echo "$API_KEY"
# System prompt
#
# System_Prompt="Before providing your answer, please ensure that you thoroughly check the information for accuracy and completeness. Consider different perspectives and relevant sources, and make any necessary adjustments to present a well-rounded and precise response. Include a separate section for mistakes and their corrections."
# System_Prompt="You are an expert in IT, specializing in networking, Linux, AWS, and Kubernetes. Provide precise, concise, and technically accurate answers. When explaining concepts, assume the user has intermediate to advanced technical knowledge. Avoid repetitive explanations of basic concepts unless explicitly requested."
System_Prompt="Note that todays date is $(date '+%D %T'). Be precise and concise"
# System_Prompt="Before providing your answer, please ensure that you thoroughly check the information for accuracy and completeness. Consider different perspectives and relevant sources, and make any necessary adjustments to present a well-rounded and precise response. Include a separate section for mistakes and their corrections."
#
# User prompt
#
# User_Prompt0="This is just a test. Make your anwser as short as possible"
alias vai='nvim ~/gitdir/skel/bash/bashrc_zen.d/ai.sh'

sanitize_input() {
  local input="$1"
  # Remove non-printable characters except for newline, and truncate to 300 characters
  Sanitized_Input=$(echo "$input" | tr -cd '[:print:]\n' | cut -c 1-${Max_Input_Tokens})
  echo "$Sanitized_Input"
}
#
# echo "$(sanitize_input "${input_stdin}")"

qo() {
  local content
  local API_KEY="${OPENROUTER_API_KEY}"
  local EndPoint="${Current_Endpoint}"
  local Model="claude-3-5-sonnet-20241022"

  # Debug information
  echo "Using Endpoint: ${EndPoint}"
  echo "Using Model: ${Model}"

  # Check if API key is set
  if [[ -z "$API_KEY" ]]; then
    echo "Error: API_KEY is not defined. Please set it and try again." >&2
    return 1
  fi

  # Check if input is provided
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    :
  else
    echo "Error: No input provided" >&2
    return 1
  fi

  # Sanitize the input and escape for JSON
  local Sanitized_Input
  Sanitized_Input=$(sanitize_input "$content" | jq -R .)
  local System_Prompt_Escaped
  System_Prompt_Escaped=$(echo "$System_Prompt" | jq -R .)

  # API call with sanitized content
  curl -s --location "${EndPoint}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${API_KEY}" \
    --header "HTTP-Referer: http://localhost:8000" \
    --data @- <<EOF | tee --append ~/temp/answers.json | jq -r '
      if (.error != null) then
        "Error: \(.error.message)"
      else
        "Prompt tokens: \(.usage.prompt_tokens)\n" +
        "Total tokens: \(.usage.total_tokens)\n" +
        "Completion tokens: \(.usage.completion_tokens)\n" +
        "Finish reason: \(.choices[0].finish_reason)\n" +
        "Model: \(.model)\n\n" +
        .choices[0].message.content
      end'
{
  "model": "${Model}",
  "messages": [
    {
      "role": "system",
      "content": ${System_Prompt_Escaped}
    },
    {
      "role": "user",
      "content": ${Sanitized_Input}
    }
  ],
  "max_tokens": ${Max_Tokens},
  "stream": false,
  "web_search": true,
  "return_search_results": true,
  "search_recency_filter": "month",
  "search_provider": "trusted",
  "search_recency_filter": "month"
}
EOF
}

qa() {
  local ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}"
  local EndPoint="https://api.anthropic.com/v1/messages"
  local Model="claude-3-5-sonnet-20241022"
  local Max_Tokens=1024

  # Check if API key is set
  if [[ -z "$ANTHROPIC_API_KEY" ]]; then
    echo "Error: ANTHROPIC_API_KEY is not defined" >&2
    return 1
  fi

  # Check if input is provided
  if [[ -n "$1" ]]; then
    local content="$1"
  elif ! tty -s && read -r content; then
    :
  else
    echo "Error: No input provided" >&2
    return 1
  fi

  curl -s "${EndPoint}" \
    --header "x-api-key: ${ANTHROPIC_API_KEY}" \
    --header "anthropic-version: 2023-06-01" \
    --header "content-type: application/json" \
    --data '{
      "model": "'"${Model}"'",
      "max_tokens": '"${Max_Tokens}"',
      "messages": [
        {"role": "user", "content": "'"${content}"'"}
      ]
    }' | jq -r '
      "Message ID: \(.id)\n" +
      "Model: \(.model)\n" +
      "Input tokens: \(.usage.input_tokens)\n" +
      "Output tokens: \(.usage.output_tokens)\n" +
      "Stop reason: \(.stop_reason)\n" +
      "\nResponse:\n\(.content[0].text)\n"
    '
}
