# Meraki api access with curl


## Get vpn status

```sh
# Get all network appliance VLANs across the org
curl -s -L --location-trusted \
  -H "Authorization: Bearer $MERAKI_API_KEY" \
  "https://api.meraki.com/api/v1/organizations/$ORG_ID/appliance/vpn/statuses" | jq '.'

# Get subnets for each network that has VLANs enabled
for NET_ID in L_660903245316622205 N_660903245316629554 N_713820540938262277 N_713820540938262278 L_660903245316622209 L_660903245316622210 N_660903245316629552; do
  echo "=== $NET_ID ==="
  curl -s -L --location-trusted \
    -H "Authorization: Bearer $MERAKI_API_KEY" \
    "https://api.meraki.com/api/v1/networks/$NET_ID/appliance/vlans" | jq '[.[] | {vlanId: .id, name: .name, subnet: .subnet}]'
  echo ""
done
```
