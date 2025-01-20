source ~/.bashrc_zen.d/api_keys_envs.sh
# 0. Import Api keys
# 1. EndPoint
# 2. Model
# 3. Max tokens
# 4. Token key
#
# Endpoint
#
PPTX_ENDPOINT="https://api.perplexity.ai/chat/completions"
OR_ENDPOINT="https://openrouter.ai/api/v1/chat/completions"

# Models
#
## Perplexity
#
# Model="llama-3.1-sonar-small-128k-online" # 8B
# Model="llama-3.1-sonar-large-128k-online" # 70B
PPTX_MODEL="llama-3.1-sonar-huge-128k-online" # 405B
# OR_MODEL="mistralai/ministral-8b"
# OR_MODEL="mistralai/ministral-8b"
#
## OpenRouter
#
# OR_MODEL="mistralai/mistral-nemo"
# OR_MODEL="deepseek/deepseek-chat"
OR_MODEL="anthropic/claude-3.5-sonnet"
# OR_MODEL="minimax/minimax-01"
# OR_MODEL="deepseek/deepseek-r1"
#
# Tokens
#
Max_Input_Tokens=2048
Max_Tokens=500
#
# API Key
#
# API_KEY="${PERPLEXITY_API_KEY}"
# API_KEY="${OPENROUTER_API_KEY}"
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

qx() {
  local content
  local API_KEY=
  local EndPoint=

  # Check if API key is set
  if [[ -z "$API_KEY" ]]; then
    echo "Error: API_KEY is not defined. Please set it and try again." >&2
    return 1
  fi

  # Check if input is provided either as a parameter or from stdin
  local content
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    : # Input from stdin
  else
    echo "Error: No input provided. Please provide input as a parameter or via stdin." >&2
    return 1
  fi

  # Sanitize the input
  local Sanitized_Input
  Sanitized_Input=$(sanitize_input "$content")

  # API call with sanitized content
  curl -s --location "${EndPoint}" \
    --header 'Accept: Application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${API_KEY}" \
    --data '{
      "model": "'"${Model}"'",
      "stream": false,
      "return_related_questions": false,
      "return_images": false,
      "search_recency_filter": "month",
      "max_tokens": '"${Max_Tokens}"',
      "messages": [
        {
          "role": "system",
          "content": "'"${System_Prompt}"'"
        },
        {
          "role": "user",
          "content": "'"${Sanitized_Input}"'"
        }
      ]
    }' | tee --append ~/temp/answers.json | jq -r --arg api_key "$API_KEY" '
          "Prompt tokens: \(.usage.prompt_tokens)\n" +
          "Total tokens: \(.usage.total_tokens)\n" +
          "Completion tokens: \(.usage.completion_tokens)\n" +
          "Finish reason: \(.choices[0].finish_reason)\n" +
          "Model: \(.model)\n" +
          "Abbreviated key: \($api_key | split("-")[0])\n\n" +
          .choices[0].message.content
        '

}

qp() {
  local content
  local API_KEY="${PERPLEXITY_API_KEY}"
  local EndPoint="${PPTX_ENDPOINT}"
  local Model="${PPTX_MODEL}"
  # Check if API key is set
  if [[ -z "$API_KEY" ]]; then
    echo "Error: API_KEY is not defined. Please set it and try again." >&2
    return 1
  fi

  # Check if input is provided either as a parameter or from stdin
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    : # Input from stdin
  else
    echo "Error: No input provided. Please provide input as a parameter or via stdin." >&2
    return 1
  fi

  # Sanitize the input
  local Sanitized_Input
  Sanitized_Input=$(sanitize_input "$content")

  # API call with sanitized content
  curl -s --location "${EndPoint}" \
    --header 'Accept: Application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${API_KEY}" \
    --data '{
      "model": "'"${Model}"'",
      "stream": false,
      "return_related_questions": false,
      "return_images": false,
      "search_recency_filter": "month",
      "max_tokens": '"${Max_Tokens}"',
      "messages": [
        {
          "role": "system",
          "content": "'"${System_Prompt}"'"
        },
        {
          "role": "user",
          "content": "'"${Sanitized_Input}"'"
        }
      ]
    }' | tee --append ~/temp/answers.json | jq -r --arg api_key "$API_KEY" '
          "Prompt tokens: \(.usage.prompt_tokens)\n" +
          "Total tokens: \(.usage.total_tokens)\n" +
          "Completion tokens: \(.usage.completion_tokens)\n" +
          "Finish reason: \(.choices[0].finish_reason)\n" +
          "Model: \(.model)\n" +
          "Abbreviated key: \($api_key | split("-")[0])\n\n" +
          .choices[0].message.content
        '

}

qa() {

  local content
  local API_KEY="${OPENROUTER_API_KEY}"
  local EndPoint="${OR_ENDPOINT}"
  local Model="${OR_MODEL}"

  # Check if API key is set
  if [[ -z "$API_KEY" ]]; then
    echo "Error: API_KEY is not defined. Please set it and try again." >&2
    return 1
  fi

  # Check if input is provided either as a parameter or from stdin
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    : # Input from stdin
  else
    echo "Error: No input provided. Please provide input as a parameter or via stdin." >&2
    return 1
  fi

  # Sanitize the input
  local Sanitized_Input
  Sanitized_Input=$(sanitize_input "$content")

  # API call with sanitized content
  curl -s --location "${EndPoint}" \
    --header 'Accept: Application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${API_KEY}" \
    --data '{
      "model": "'"${Model}"'",
      "stream": false,
      "return_related_questions": false,
      "return_images": false,
      "search_recency_filter": "month",
      "max_tokens": '"${Max_Tokens}"',
      "messages": [
        {
          "role": "system",
          "content": "'"${System_Prompt}"'"
        },
        {
          "role": "user",
          "content": "'"${Sanitized_Input}"'"
        }
      ]
    }' | tee --append ~/temp/answers.json | jq -r --arg api_key "$API_KEY" '
          "Prompt tokens: \(.usage.prompt_tokens)\n" +
          "Total tokens: \(.usage.total_tokens)\n" +
          "Completion tokens: \(.usage.completion_tokens)\n" +
          "Finish reason: \(.choices[0].finish_reason)\n" +
          "Model: \(.model)\n" +
          "Abbreviated key: \($api_key | split("-")[0])\n\n" +
          .choices[0].message.content
        '

}
