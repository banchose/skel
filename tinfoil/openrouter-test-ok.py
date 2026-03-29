# /// script
# requires-python = ">=3.12"
# dependencies = ["tinfoil"]
# ///
"""Send a test request to the Tinfoil chat completions API."""

import os

from tinfoil import TinfoilAI


def main() -> None:
    """Send a test chat completion and print the response."""
    client = TinfoilAI(api_key=os.environ["TINFOIL_API_KEY"])

    response = client.chat.completions.create(
        model="kimi-k2-5",
        messages=[
            {
                "role": "user",
                "content": "This is just a test. Please respond with 'OK'",
            }
        ],
    )

    print(response.choices[0].message.content)


if __name__ == "__main__":
    main()
