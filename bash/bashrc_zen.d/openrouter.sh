or-curl() {
  curl -X POST https://openrouter.ai/api/v1/chat/completions \
    -H "Authorization: Bearer ${OPENROUTER_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "messages": [
    {
      "role": "user",
      "content": "This is just a test message. Provide a very brief acknowlegement"
    }
  ]
}'
}
