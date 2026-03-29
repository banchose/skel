# /// script
# requires-python = ">=3.12"
# dependencies = ["tinfoil"]
# ///
"""Send a test request to the OpenRouter chat completions API."""

import os

import requests


def main() -> None:
    """Send a single chat completion request and print the response."""
    api_key = os.environ["OPENROUTER_API_KEY"]

    response = requests.post(
        url="https://openrouter.ai/api/v1/chat/completions",
        headers={
            "Authorization": f"Bearer {api_key}",  # 1. Was missing f-string and space
        },
        json={  # 2. Use json= instead of data=json.dumps()
            "model": "anthropic/claude-sonnet-4-6",  # 3. Remove leading slash
            "messages": [
                {
                    "role": "user",
                    "content": "This is just a test. Please respond with 'OK'",
                }
            ],
            "plugins": [{"id": "web"}],
        },
    )

    response.raise_for_status()  # 4. Fail loudly on HTTP errors
    print(response.json())  # 5. Print the parsed JSON, not the Response object


if __name__ == "__main__":
    main()
