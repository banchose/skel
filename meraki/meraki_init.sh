[[ -n "${MERAKI_API_KEY}" ]] || {
  echo "no MERAKI_API_KEY"
  return 1
}
export MERAKI_ENDPOINT=https://api.meraki.com/api/v1
export MERAKI_HEADER="Authorization: Bearer ${MERAKI_API_KEY}"
export MERAKI_HRI_ORG=770210

# curl -sSL "${MERAKI_ENDPOINT}/organizations/${MERAKI_HRI_ORG}/devices" -H "${MERAKI_HEADER}" |
# jq -r '.[]|select(.model|startswith("MX250"))|[.serial,.name,.networkId]|@tsv'

m() { curl -sSL "${MERAKI_ENDPOINT}$1" -H "Authorization: Bearer ${MERAKI_API_KEY}"; }

m /organizations
