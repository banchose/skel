# pptxmodel="llama-3.1-sonar-small-128k-online" # 8B
# pptxmodel="llama-3.1-sonar-large-128k-online" # 70B
# pptxmodel="llama-3.1-sonar-huge-128k-online" # 405B

Model="llama-3.1-sonar-small-128k-online" # 8B
# Model="llama-3.1-sonar-large-128k-online" # 70B
# Model="llama-3.1-sonar-huge-128k-online" # 405B

Max_Input_Tokens=2048
Max_Tokens=150

# Perplexity_AI_EndPoint="https://api.perplexity.ai/chat/completions"

API_KEY="${PERPLEXITY_API_KEY}"

Chat_EndPoint="https://api.perplexity.ai/chat/completions"
#
# System prompt
#
# System_Prompt="Before providing your answer, please ensure that you thoroughly check the information for accuracy and completeness. Consider different perspectives and relevant sources, and make any necessary adjustments to present a well-rounded and precise response. Include a separate section for mistakes and their corrections."
# System_Prompt="You are an expert in IT, specializing in networking, Linux, AWS, and Kubernetes. Provide precise, concise, and technically accurate answers. When explaining concepts, assume the user has intermediate to advanced technical knowledge. Avoid repetitive explanations of basic concepts unless explicitly requested."
System_Prompt="Be precise and concise"
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

qa() {
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
  curl -s --location "${Chat_EndPoint}" \
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
    }' | tee --append ~/temp/answers.json | jq -r '
          "Prompt tokens: \(.usage.prompt_tokens)\n" +
          "Total tokens: \(.usage.total_tokens)\n" +
          "Completion tokens: \(.usage.completion_tokens)\n" +
          "Finish reason: \(.choices[0].finish_reason)\n" +
          "Model: \(.model)\n\n" +
          .choices[0].message.content
        '

}
