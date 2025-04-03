curl -X POST https://api.porkbun.com/api/json/v3/ping \
  -H "Content-Type: application/json" \
  -d '{
    "secretapikey": "'"${PORKBUN_SECRET_KEY}"'",
    "apikey": "'"${PORKBUN_API_KEY}"'"
  }'
