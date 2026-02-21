source ~/.bashrc_zen.d/api_keys_envs.sh
# 0. Import Api keys
# 1. EndPoint
# 2. Model
# 3. Max tokens
# 4. Token key
#
# Endpoint
#

# Models
#
#
## OpenRouter
#
# OR_MODEL="mistralai/mistral-nemo"
# OR_MODEL="deepseek/deepseek-chat"
# OR_MODEL="anthropic/claude-3.5-sonnet"
# OR_MODEL="meta-llama/llama-3.3-70b-instruct"
# OR_MODEL="anthropic/claude-3.5-haiku"
# OR_MODEL="anthropic/claude-3.5-sonnet"
# OR_MODEL="anthropic/claude-3.7-sonnet"
OR_MODEL="anthropic/claude-sonnet-4"
OR_MODEL_QUICK=mistralai/mistral-small-3.1-24b-instruct
# OR_MODEL="mistralai/mistral-large-2411"
# OR_MODEL="minimax/minimax-01"
# OR_MODEL="deepseek/deepseek-r1"
# OR_MODEL="anthropic/claude-3-opus"
OPENROUTER_ENDPOINT="https://openrouter.ai/api/v1/chat/completions"
Current_Model="${OR_MODEL}"

# ANTHROPIC OR_MODEL
#
# ANTHROPIC_MODEL="claude-haiku-4-5-20251001"
#
HAIKU="claude-haiku-4-5-20251001"
SONNET="claude-sonnet-4-5-20250929"
# ANTHROPIC_MODEL="claude-sonnet-4-5-20250929"
# ANTHROPIC_MODEL="us.anthropic.claude-opus-4-6-v1"

# Tokens
#
Max_Input_Tokens=2048
Max_Tokens=2048
#
# API Key
#
# echo "$API_KEY"
# System prompt
#
# System_Prompt="Before providing your answer, please ensure that you thoroughly check the information for accuracy and completeness. Consider different perspectives and relevant sources, and make any necessary adjustments to present a well-rounded and precise response. Include a separate section for mistakes and their corrections."
# System_Prompt="You are an expert in IT, specializing in networking, Linux, AWS, and Kubernetes. Provide precise, concise, and technically accurate answers. When explaining concepts, assume the user has intermediate to advanced technical knowledge. Avoid repetitive explanations of basic concepts unless explicitly requested."
System_Prompt="Note that todays date is $(date '+%D %T'). I prioritize receiving candid feedback and alternative perspectives that might reveal simpler or more effective approaches over responses that simply agree with my position. Please challenge my assumptions when warranted and share insights about best practices, even if they differ from my current approach."
# System_Prompt="Before providing your answer, please ensure that you thoroughly check the information for accuracy and completeness. Consider different perspectives and relevant sources, and make any necessary adjustments to present a well-rounded and precise response. Include a separate section for mistakes and their corrections."
#
# User prompt
#
#
# Read openrouter exported chats
#
#  cat ./openrouter-export.json | jq -r '.messages[] | select(.content != null) | .content'
#
#
#
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
#   cat ./FOWARDER-RULE-TO-HEALTHRESEARCH-ORG.json | jq -r '.messages[] | select(.content != null) | .content'
#   cat ./FOWARDER-RULE-TO-HEALTHRESEARCH-ORG.json | jq -r '.messages[] | select(.characterId == "USER" and .content != null) | .content'
#   cat ./FOWARDER-RULE-TO-HEALTHRESEARCH-ORG.json | jq -r '.messages[] | select(.characterId == "char-1741271155-P4PhggbFhRwtqwMniCB0" and .content != null) | .content'
#
qo() {
  local content
  local API_KEY="${OPENROUTER_API_KEY}"
  local EndPoint="${OPENROUTER_ENDPOINT}"
  local Model="${OR_MODEL}"

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

qq() {
  local content
  local API_KEY="${OPENROUTER_API_KEY}"
  local EndPoint="${OPENROUTER_ENDPOINT}"
  local Model="${OR_MODEL_QUICK}"

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

ailsma() {
  if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    echo "Error: ANTHROPIC_API_KEY environment variable is not set." >&2
    return 1
  fi

  local response
  response=$(curl -s "https://api.anthropic.com/v1/models" \
    --header "x-api-key: ${ANTHROPIC_API_KEY}" \
    --header "anthropic-version: 2023-06-01")

  # Check if curl command succeeded
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to connect to Anthropic API." >&2
    return 2
  fi

  # Check if the response contains an error
  if echo "${response}" | jq -e 'has("error")' >/dev/null; then
    echo "Error from Anthropic API: $(echo "${response}" | jq -r '.error.message')" >&2
    return 3
  fi

  # Pretty print the models one per line
  echo "${response}" | jq -r '.data[] | "\(.display_name) (\(.id)) - Released: \(.created_at | fromdateiso8601 | strftime("%Y-%m-%d"))"'
}

qa() {
  local ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}"
  local EndPoint="https://api.anthropic.com/v1/messages"
  local Model="${ANTHROPIC_MODEL:-claude-3-haiku-20240307}" # Default if not set
  local Max_Tokens=1024
  local Verbose=false # Keep verbose flag for potential future use, but stats print always

  # Basic CLI parsing for -v (optional - could be removed if only stats matter)
  if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    Verbose=true
    shift
  fi

  echo "Using Endpoint: ${EndPoint}"
  echo "Using Model: ${Model}"

  if [[ -z "$ANTHROPIC_API_KEY" ]]; then
    echo "Error: ANTHROPIC_API_KEY is not defined. Please set it." 1>&2
    return 1
  fi

  local content
  # Handle piped input like qo does (optional, but good practice)
  if [[ -n "$1" ]]; then
    content="$1"
  else
    # Check if input is from a pipe/redirect and read it
    if ! tty -s && IFS= read -r content; then
      : # Content read from pipe/redirect
    else
      echo "Usage: qa [-v] \"your message\"  OR  echo \"your message\" | qa [-v]" 1>&2
      return 1
    fi
  fi

  # Prepare payload using jq for safety
  local payload
  payload=$(jq -cn --arg model "$Model" \
    --arg content "$content" \
    --argjson max_tokens "$Max_Tokens" \
    '{
                       model: $model,
                       max_tokens: $max_tokens,
                       messages: [{role: "user", content: $content}]
                   }')

  # Make the API call and process the response
  curl -s --location "$EndPoint" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "Content-Type: application/json" \
    -d "$payload" |
    # Optionally tee the raw response like qo
    # tee --append ~/temp/anthropic_answers.json |
    jq -r '
        # Handle API errors first
        if .error then
          "Error: \(.error.type) - \(.error.message)"

        # Handle successful responses with content
        elif .content and (.content | length > 0) and .usage then
          # Calculate total tokens
          (.usage.input_tokens + .usage.output_tokens) as $total_tokens |

          # Format stats similar to qo
          "Input tokens: \(.usage.input_tokens)\n" +
          "Output tokens: \(.usage.output_tokens)\n" +
          "Total tokens: \($total_tokens)\n" +
          "Stop reason: \(.stop_reason // "N/A")\n" + # Use // for default if null
          "Model: \(.model)\n\n" +

          # Extract and join the actual message content
          (.content | map(select(.type == "text") | .text) | join("\n"))

        # Handle other unexpected response formats
        else
          "Unexpected response format or empty content:\n\(.)"
        end
    '

  # Optionally capture and return the exit status of jq (or curl if tee isn't used)
  return "${PIPESTATUS[${#PIPESTATUS[@]} - 1]}"
}

ailsmo() {
  if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
    echo "Error: OPENROUTER_API_KEY environment variable is not set." >&2
    return 1
  fi

  # Inform the user that we're fetching data
  echo -e "\033[1;34mFetching model information from OpenRouter API...\033[0m"

  local response
  response=$(curl -s "https://openrouter.ai/api/v1/models" \
    --header "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    --header "Content-Type: application/json")

  # Check if curl command succeeded
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to connect to OpenRouter API." >&2
    return 2
  fi

  # Check if the response contains an error
  if echo "${response}" | jq -e 'has("error")' >/dev/null; then
    echo "Error from OpenRouter API: $(echo "${response}" | jq -r '.error.message // .error')" >&2
    return 3
  fi

  # Get total model count
  local model_count
  model_count=$(echo "${response}" | jq '.data | length')
  echo -e "\033[1;32mFound ${model_count} available models\033[0m"

  # Sort models by provider and name
  local sorted_response
  sorted_response=$(echo "${response}" | jq '.data | sort_by(.id)')

  # Format the header
  printf "%-35s %-30s %-12s\n" "MODEL NAME" "MODEL ID" "CONTEXT"
  printf "%-35s %-30s %-12s\n" "$(printf '%*s' 35 '' | tr ' ' '-')" "$(printf '%*s' 30 '' | tr ' ' '-')" "$(printf '%*s' 12 '' | tr ' ' '-')"

  # Extract and display provider groups
  local current_provider=""

  echo "${sorted_response}" | jq -r '.[] | 
        .id as $full_id |
        ($full_id | split("/")[0]) as $provider |
        ($full_id | split("/")[1]) as $model_id |
        .name as $display_name |
        .context_length as $context |
        [$provider, $display_name, $model_id, $context] | @tsv
    ' | while IFS=$'\t' read -r provider display_name model_id context; do
    # Print provider header when provider changes
    if [[ "${provider}" != "${current_provider}" ]]; then
      printf "\n\033[1;36m%s\033[0m\n" "=== ${provider^^} ==="
      current_provider="${provider}"
    fi

    # Print model details
    printf "%-35s %-30s %-12s\n" "${display_name:0:35}" "${model_id:0:30}" "${context}"
  done

  echo -e "\n\033[1;37mNote:\033[0m For model pricing information, visit \033[4mhttps://openrouter.ai/docs#models\033[0m"
}

######################## EXAMPLES #######################
# Using curl for a more complete submission
#
# curlaiapiexamp() {
#     if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
#         echo "Error: OPENROUTER_API_KEY environment variable is not set." >&2
#         return 1
#     fi
#
#     # Model selection with system role
#     local model_id="anthropic/claude-3-haiku-20240307"
#     local system_role="Be concise and precise."
#     local prompt="Explain quantum computing in simple terms."
#
#     local response
#     response=$(curl -s "https://openrouter.ai/api/v1/chat/completions" \
#         -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
#         -H "Content-Type: application/json" \
#         -d '{
#             "model": "'"${model_id}"'",
#             "messages": [
#                 {"role": "system", "content": "'"${system_role}"'"},
#                 {"role": "user", "content": "'"${prompt}"'"}
#             ]
#         }')
#
#     # Extract and display the response content
#     echo "${response}" | jq -r '.choices[0].message.content'
# }
#
# curl https://api.anthropic.com/v1/messages \
#      --header "x-api-key: $ANTHROPIC_API_KEY" \
#      --header "anthropic-version: 2023-06-01" \
#      --header "content-type: application/json" \
#      --data \
# '{
#     "model": "claude-3-7-sonnet-20250219",
#     "max_tokens": 1024,
#     "messages": [
#         {"role": "user", "content": "Hello, world"}
#     ]
# }'
