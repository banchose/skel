#!/usr/bin/env python

# %%timeit -n 1 -r 1
import requests
import os

api_data = {
    "secretapikey": os.environ["PORKBUN_SECRET_KEY"],
    "apikey": os.environ["PORKBUN_API_KEY"],
}
response = requests.post("https://api.porkbun.com/api/json/v3/ping", json=api_data)
