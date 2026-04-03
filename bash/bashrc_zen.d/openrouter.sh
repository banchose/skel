or_curl() {
  curl -X POST https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "model": "anthropic/claude-sonnet-4-6",
  "cache_control": { "type": "ephemeral" },
  "messages": [
    {
      "role": "user",
      "content": "This is just a test message. Provide a very brief acknowlegement"
    }
  ]
}'
}

or_curl_caching() {
  curl -X POST https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "model": "anthropic/claude-sonnet-4-6",
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "type": "text",
          "text": "Your large system prompt or document here...",
          "cache_control": { "type": "ephemeral" }
        }
      ]
    },
    {
      "role": "user",
      "content": [{ "type": "text", "text": "Your question" }]
    }
  ]
}'
}

or_curl_tool_date() {

  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
    "model": "anthropic/claude-sonnet-4-6",
    "messages": [
      {
        "role": "user",
        "content": "What day of the week is it today?"
      }
    ],
    "tools": [
      {
        "type": "openrouter:datetime",
        "parameters": {
        "timezone": "America/New_York"
        }
      }
    ]
  }'
}

or_curl_env_model() {
  curl -X POST https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "model": "'"${OR_MODEL_OVERRIDE:-anthropic/claude-sonnet-4-6}"'",
  "messages": [
    {
      "role": "user",
      "content": "This is just a test message. Provide a very brief acknowlegement"
    }
  ]
}'
}

or_list_models() {
  ## Supported Parameters
  # curl "https://openrouter.ai/api/v1/models?supported_parameters=tools"
  ## Image generation models only
  # curl "https://openrouter.ai/api/v1/models?output_modalities=image"
  ## Text and image models
  # curl "https://openrouter.ai/api/v1/models?output_modalities=text,image"
  ## All models regardless of modality
  # curl "https://openrouter.ai/api/v1/models?output_modalities=all"
  ## Default — text models only
  curl -s https://openrouter.ai/api/v1/models \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json"
}
