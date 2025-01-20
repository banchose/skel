# pptxmodel="llama-3.1-sonar-small-128k-online" # 8B
# pptxmodel="llama-3.1-sonar-large-128k-online" # 70B
pptxmodel="llama-3.1-sonar-huge-128k-online" # 405B

system_pompt0="Before providing your answer, please ensure that you thoroughly check the information for accuracy and completeness. Consider different perspectives and relevant sources, and make any necessary adjustments to present a well-rounded and precise response. Include a separate section for mistakes and their corrections."

maxinput=2048
maxtokens=150

system_content="You are an expert in IT, specializing in networking, Linux, AWS, and Kubernetes. Provide precise, concise, and technically accurate answers. When explaining concepts, assume the user has intermediate to advanced technical knowledge. Avoid repetitive explanations of basic concepts unless explicitly requested."

sanitize_input() {
  local input="$1"
  # Remove non-printable characters except for newline, and truncate to 300 characters
  sanitized_input=$(echo "$input" | tr -cd '[:print:]\n' | cut -c 1-${maxinput})
  echo "$sanitized_input"
}

query_perplexity() {
  # Check if API key is set
  if [[ -z "$PERPLEXITY_API_KEY" ]]; then
    echo "Error: PERPLEXITY_API_KEY is not defined. Please set it and try again." >&2
    exit 1
  fi

  # Check if input is provided either as a parameter or from stdin
  local content
  if [[ -n "$1" ]]; then
    content="$(sanitize_input "$1")"
  elif ! tty -s && read -r input_stdin; then
    content="$(sanitize_input "${input_stdin}")"
  else
    echo "Error: No input provided. Please provide input as a parameter or via stdin." >&2
    exit 1
  fi

  # Sanitize the input
  local sanitized_input
  sanitized_input=$(sanitize_input "$content")
  # API call with sanitized content
  curl -s --location 'https://api.perplexity.ai/chat/completions' \
    --header 'accept: application/json' \
    --header 'content-type: application/json' \
    --header "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
    --data '{
      "model": "'"${pptxmodel}"'",
      "stream": false,
      "return_related_questions": false,
      "return_images": false,
      "search_recency_filter": "month",
      "max_tokens": '"${maxtokens}"',
      "messages": [
        {
          "role": "system",
          "content": "Be precise and concise."
        },
        {
          "role": "user",
          "content": "'"${sanitized_input}"'"
        }
      ]
    }' | tee --append ~/temp/answers.json | jq '.'
}

qp() {
  # Check if API key is set
  if [[ -z "$PERPLEXITY_API_KEY" ]]; then
    echo "Error: PERPLEXITY_API_KEY is not defined. Please set it and try again." >&2
    exit 1
  fi

  # Check if input is provided either as a parameter or from stdin
  local content
  if [[ -n "$1" ]]; then
    content="$1"
  elif ! tty -s && read -r content; then
    : # Input from stdin
  else
    echo "Error: No input provided. Please provide input as a parameter or via stdin." >&2
    exit 1
  fi

  # Sanitize the input
  local sanitized_input
  sanitized_input=$(sanitize_input "$content")

  # API call with sanitized content
  curl -s --location 'https://api.perplexity.ai/chat/completions' \
    --header 'accept: application/json' \
    --header 'content-type: application/json' \
    --header "Authorization: Bearer ${PERPLEXITY_API_KEY}" \
    --data '{
      "model": "'"${pptxmodel}"'",
      "stream": false,
      "return_related_questions": false,
      "return_images": false,
      "search_recency_filter": "month",
      "max_tokens": '"${maxtokens}"',
      "messages": [
        {
          "role": "system",
          "content": "Be precise and concise. Conserve output tokens were possible."
        },
        {
          "role": "user",
          "content": "'"${sanitized_input}"'"
        }
      ]
    }' | tee --append ~/temp/answers.json | jq -r '
          "Prompt tokens: \(.usage.prompt_tokens)\n" +
          "Total tokens: \(.usage.total_tokens)\n" +
          "Completion tokens: \(.usage.completion_tokens)\n" +
          "Finish reason: \(.choices[0].finish_reason)\n" +
          "Model: \(.model)\n\n" +
          .choices[0].message.content
        '

}
# jq '{prompt_tokens: .usage.prompt_tokens, total_tokens: .usage.total_tokens, Model: .model, Answer: .choices[0].message.content}'
#
# tee --append ~/temp/answers.json | jq -r '{prompt_tokens: .usage.prompt_tokens, total_tokens: .usage.total_tokens, completion_tokens: .usage.completion_tokens, Model: .model, Answer: .choices[0].message.content}'
#
# Example usage:
# Passing input as a parameter:
# query_perplexity "Your input content here..."

# Passing input via stdin:
# echo "Your input content here..." | query_perplexity
