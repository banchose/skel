#!/usr/bin/env python

import requests
import os
import json
from datetime import datetime

api_data = {
    "secretapikey": os.environ["PORKBUN_SECRET_KEY"],
    "apikey": os.environ["PORKBUN_API_KEY"],
}

print(f"[{datetime.now()}] Starting Porkbun API call...")

try:
    response = requests.post(
        "https://api.porkbun.com/api/json/v3/dns/retrieve/xaax.dev", json=api_data
    )

    # Detailed response info
    print(f"Status Code: {response.status_code}")
    print(f"Response Time: {response.elapsed.total_seconds():.3f} seconds")
    print(f"Response Size: {len(response.content)} bytes")
    print(f"Content Type: {response.headers.get('content-type', 'Unknown')}")

    # Headers (more readable)
    print("\n=== HEADERS ===")
    for key, value in response.headers.items():
        print(f"{key}: {value}")

    # Response body
    print("\n=== RESPONSE ===")
    if response.status_code == 200:
        result = response.json()
        print(f"API Status: {result.get('status', 'Unknown')}")
        print(f"Records Found: {len(result.get('records', []))}")

        # Pretty print the JSON
        print("\nFull Response:")
        print(json.dumps(result, indent=2))
    else:
        print(f"HTTP Error {response.status_code}: {response.text}")

except requests.exceptions.RequestException as e:
    print(f"Request Error: {e}")
except KeyError as e:
    print(f"Environment Variable Missing: {e}")
except json.JSONDecodeError as e:
    print(f"JSON Decode Error: {e}")
except Exception as e:
    print(f"Unexpected Error: {e}")

print(f"\n[{datetime.now()}] Script completed.")
