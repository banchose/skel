#!/usr/bin/env bash

set -ueo pipefail

curl -X POST https://api.porkbun.com/api/json/v3/domain/listAll \
  -H "Content-Type: application/json" \
  -d '{
    "secretapikey": "'"${PORKBUN_SECRET_KEY}"'",
    "apikey": "'"${PORKBUN_API_KEY}"'",
    "start": "1",
    "includeLabels": "yes"
  }'
