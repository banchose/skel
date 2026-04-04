#!/bin/bash
# ~/.bashrc_zen.d/api_keys_envs.sh

# ===== API CONFIGURATION =====
# Ensure API keys are loaded from a secure location
# They should be defined elsewhere and available as environment variables

# ===== MODEL CONFIGURATION =====
# OpenRouter Models - uncomment just one to set as default
# OR_MODEL="mistralai/mistral-nemo"
# OR_MODEL="deepseek/deepseek-chat"
# OR_MODEL="anthropic/claude-3.5-sonnet"
# OR_MODEL="meta-llama/llama-3.3-70b-instruct"
# OR_MODEL="anthropic/claude-3.5-haiku"
# OR_MODEL="mistralai/mistral-large-2411"
# OR_MODEL="minimax/minimax-01"
# OR_MODEL="deepseek/deepseek-r1"
# OR_MODEL="anthropic/claude-3-opus"
OR_MODEL="anthropic/claude-3.7-sonnet"
OR_MODEL_QUICK="mistralai/mistral-small-3.1-24b-instruct"

# Anthropic Models
ANTHROPIC_MODEL="claude-3-7-sonnet-20250219"

# API Endpoints
OPENROUTER_ENDPOINT="https://openrouter.ai/api/v1/chat/completions"
ANTHROPIC_ENDPOINT="https://api.anthropic.com/v1/messages"

# Current model selection
Current_Model="${OR_MODEL}"

# ===== TOKEN CONFIGURATION =====
Max_Input_Tokens=2048
Max_Tokens=2048

# ===== SYSTEM PROMPTS =====
# Default system prompt with current date
System_Prompt="Note that today's date is $(date '+%Y-%m-%d %H:%M:%S'). I prioritize receiving candid feedback and alternative perspectives that might reveal simpler or more effective approaches over responses that simply agree with my position. Please challenge my assumptions when warranted and share insights about best practices, even if they differ from my current approach."

# Alternative prompts (commented out)
# System_Prompt="You are an expert in IT, specializing in networking, Linux, AWS, and Kubernetes. Provide precise, concise, and technically accurate answers. When explaining concepts, assume the user has intermediate to advanced technical knowledge. Avoid repetitive explanations of basic concepts unless explicitly requested."
# System_Prompt="Before providing your answer, please ensure that you thoroughly check the information for accuracy and completeness. Consider different perspectives and relevant sources, and make any necessary adjustments to present a well-rounded and precise response. Include a separate section for mistakes and their corrections."

# ===== ALIASES =====
alias vai='nvim ~/gitdir/skel/bash/bashrc_zen.d/ai.sh'

# ===== UTILITY FUNCTIONS =====
# Sanitize user input by removing non-printable characters and truncating
sanitize_input() {
  local input="$1"
  local max_length="${2:-$Max_Input_Tokens}"
  # Remove non-printable characters except for newline, and truncate
  echo "$input" | tr -cd '[:print:]\n' | cut -c 1-"${max_length}"
}

# Check if API key is available
check_api_key() {
  local key_var="$1"
  local key_name="$2"

  if [[ -z "${!key_var}" ]]; then
    echo "Error: ${key_name} is not defined. Please set it and try again." >&2
    return 1
  fi
  return 0
}

# Format JSON response for consistent output
format_response() {
  local response="$1"
  local verbose="$2"

  if [[ "$verbose" == "true" ]]; then
    jq -r '
        if (.error != null) then
            "Error: \(.error.message // .error)"
        else
            "Prompt tokens: \(.usage.prompt_tokens // "N/A")\n" +
            "Total tokens: \(.usage.total_tokens // "N/A")\n" +
            "Completion tokens: \(.usage.completion_tokens // "N/A")\n" +
            "Finish reason: \(.choices[0].finish_reason // "N/A")\n" +
            "Model: \(.model // "N/A")\n\n" +
            (.choices[0].message.content)
        end' <<<"$response"
  else
    jq -r '
        if (.error != null) then
            "Error: \(.error.message // .error)"
        else
            .choices[0].message.content
        end' <<<"$response"
  fi
}

# ===== OPENROUTER FUNCTIONS =====

# Standard OpenRouter query function
qo() {
  local content
  local verbose=false

  # Handle verbose flag
  if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    verbose=true
    shift
  fi

  # Check API key
  if ! check_api_key "OPENROUTER_API_KEY" "OpenRouter API Key"; then
    return 1
  fi

  # Debug information
  if [[ "$verbose" == "true" ]]; then
    echo "Using Endpoint: ${OPENROUTER_ENDPOINT}"
    echo "Using Model: ${OR_MODEL}"
  fi

  # Get content from argument or stdin
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    :
  else
    echo "Error: No input provided" >&2
    echo "Usage: qo [-v|--verbose] \"your prompt\"" >&2
    return 1
  fi

  # Sanitize and escape input for JSON
  local sanitized_input
  sanitized_input=$(sanitize_input "$content" | jq -Rs .)
  local system_prompt_escaped
  system_prompt_escaped=$(echo "$System_Prompt" | jq -Rs .)

  # Construct the payload using a heredoc
  local payload
  payload=$(
    cat <<EOF
{
  "model": "${OR_MODEL}",
  "messages": [
    {
      "role": "system",
      "content": ${system_prompt_escaped}
    },
    {
      "role": "user",
      "content": ${sanitized_input}
    }
  ],
  "max_tokens": ${Max_Tokens},
  "stream": false,
  "web_search": true,
  "return_search_results": true,
  "search_recency_filter": "month",
  "search_provider": "trusted"
}
EOF
  )

  # Make the API call
  local response
  response=$(curl -s --location "${OPENROUTER_ENDPOINT}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    --header "HTTP-Referer: http://localhost:8000" \
    --data "$payload")

  # Save response to log file
  echo "$response" >>~/temp/answers.json

  # Format the response
  format_response "$response" "$verbose"
}

# Quick query function using faster model
qq() {
  local content
  local verbose=false

  # Handle verbose flag
  if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    verbose=true
    shift
  fi

  # Check API key
  if ! check_api_key "OPENROUTER_API_KEY" "OpenRouter API Key"; then
    return 1
  fi

  # Debug information
  if [[ "$verbose" == "true" ]]; then
    echo "Using Endpoint: ${OPENROUTER_ENDPOINT}"
    echo "Using Model: ${OR_MODEL_QUICK}"
  fi

  # Get content from argument or stdin
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    :
  else
    echo "Error: No input provided" >&2
    echo "Usage: qq [-v|--verbose] \"your prompt\"" >&2
    return 1
  fi

  # Sanitize and escape input for JSON
  local sanitized_input
  sanitized_input=$(sanitize_input "$content" | jq -Rs .)
  local system_prompt_escaped
  system_prompt_escaped=$(echo "$System_Prompt" | jq -Rs .)

  # Construct the payload
  local payload
  payload=$(
    cat <<EOF
{
  "model": "${OR_MODEL_QUICK}",
  "messages": [
    {
      "role": "system",
      "content": ${system_prompt_escaped}
    },
    {
      "role": "user",
      "content": ${sanitized_input}
    }
  ],
  "max_tokens": ${Max_Tokens},
  "stream": false,
  "web_search": true,
  "return_search_results": true,
  "search_recency_filter": "month",
  "search_provider": "trusted"
}
EOF
  )

  # Make the API call
  local response
  response=$(curl -s --location "${OPENROUTER_ENDPOINT}" \
    --header 'Accept: application/json' \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    --header "HTTP-Referer: http://localhost:8000" \
    --data "$payload")

  # Save response to log file
  echo "$response" >>~/temp/answers.json

  # Format the response
  format_response "$response" "$verbose"
}

# ===== ANTHROPIC FUNCTIONS =====

# Anthropic API query
qa() {
  local content
  local verbose=false
  local max_tokens="${Max_Tokens}"

  # Handle verbose flag
  if [[ "$1" == "-v" || "$1" == "--verbose" ]]; then
    verbose=true
    shift
  fi

  # Check API key
  if ! check_api_key "ANTHROPIC_API_KEY" "Anthropic API Key"; then
    return 1
  fi

  # Get content from argument or stdin
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    :
  else
    echo "Error: No input provided" >&2
    echo "Usage: qa [-v|--verbose] \"your prompt\"" >&2
    return 1
  fi

  # Sanitize input
  content=$(sanitize_input "$content")

  # Construct payload using jq
  local payload
  payload=$(jq -n --arg model "$ANTHROPIC_MODEL" --arg content "$content" --argjson max_tokens "$max_tokens" '{
        model: $model, 
        max_tokens: $max_tokens, 
        messages: [{role: "user", content: $content}]
    }')

  # Make API call
  local response
  response=$(curl -s "$ANTHROPIC_ENDPOINT" \
    -H "x-api-key: $ANTHROPIC_API_KEY" \
    -H "anthropic-version: 2023-06-01" \
    -H "Content-Type: application/json" \
    -d "$payload")

  # Process response
  if [[ "$verbose" == "true" ]]; then
    echo "$response" | jq -r '
            if .error then
                "Error: \(.error.message)"
            elif .content and (.content | length > 0) then
                "Message ID: \(.id)\n" +
                "Model: \(.model)\n" +
                "Input tokens: \(.usage.input_tokens)\n" +
                "Output tokens: \(.usage.output_tokens)\n" +
                "Stop reason: \(.stop_reason)\n\n" +
                "Response:\n" + (.content | map(select(.type == "text") | .text) | join("\n"))
            else
                "Unexpected response format: \(.)"
            end'
  else
    echo "$response" | jq -r '
            if .error then
                "Error: \(.error.message)"
            elif .content and (.content | length > 0) then
                .content | map(select(.type == "text") | .text) | join("\n")
            else
                "Unexpected response format. Use -v for details."
            end'
  fi
}

# ===== MODEL LISTING FUNCTIONS =====

# List Anthropic models
ailsma() {
  # Check API key
  if ! check_api_key "ANTHROPIC_API_KEY" "Anthropic API Key"; then
    return 1
  fi

  echo "Fetching Anthropic models..."

  # Make API call
  local response
  response=$(curl -s "https://api.anthropic.com/v1/models" \
    --header "x-api-key: ${ANTHROPIC_API_KEY}" \
    --header "anthropic-version: 2023-06-01")

  # Check for API errors
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

# List OpenRouter models
ailsmo() {
  # Check API key
  if ! check_api_key "OPENROUTER_API_KEY" "OpenRouter API Key"; then
    return 1
  fi

  # Inform the user that we're fetching data
  echo -e "\033[1;34mFetching model information from OpenRouter API...\033[0m"

  # Make API call
  local response
  response=$(curl -s "https://openrouter.ai/api/v1/models" \
    --header "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    --header "Content-Type: application/json")

  # Check for errors
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to connect to OpenRouter API." >&2
    return 2
  fi

  if echo "${response}" | jq -e 'has("error")' >/dev/null; then
    echo "Error from OpenRouter API: $(echo "${response}" | jq -r '.error.message // .error')" >&2
    return 3
  fi

  # Process response
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
