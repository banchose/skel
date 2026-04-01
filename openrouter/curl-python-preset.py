import requests
import json
import os

url = "https://openrouter.ai/api/v1/chat/completions"
headers = {
    "Authorization": f"Bearer {os.environ.get('OPENROUTER_API_KEY')}",
    "Content-Type": "application/json",
}
payload = {
    "preset": "@preset/bash-skill",
    "model": "anthropic/claude-sonnet-4-6",
    "messages": [
        {"role": "user", "content": "This is a test message.  Respond with 'OK'"}
    ],
}

response = requests.post(url, headers=headers, json=payload)
print(response.json())
