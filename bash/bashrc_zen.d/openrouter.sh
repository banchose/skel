DefaultContent="Be very concise and give me a 6 word sentence"
# Model="deepseek/deepseek-chat"
Model="mistralai/ministral-8b"

or() {
  curl -s https://openrouter.ai/api/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -d '{
  "model": "'"${Model}"'",
  "messages": [
     {
       "role": "user",
       "content": "'"${DefaultContent}"'"
     }
   ]
  
  }' | jq '.'
}
