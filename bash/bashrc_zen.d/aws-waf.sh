aws_get_waf_ips() {

  aws logs tail aws-waf-logs-HRI-APP-WAF --follow --since 1h --region us-east-1 --profile net | stdbuf -oL grep -oP '\{.*\}' | jq --unbuffered 'select(
  (.httpRequest.headers[] | select(.name == "host") | .value) == "ono.healthresearch.org"
) | {
  action: .action,
  clientIp: .httpRequest.clientIp,
  uri: .httpRequest.uri,
  country: .httpRequest.country
}'
}

aws_waf_get_ipset() {
  aws wafv2 get-ip-set \
    --scope REGIONAL --region us-east-1 --profile net \
    --name HRI-APP-WAF-testsite-allowed-ips \
    --id 4c1ecf5f-ab59-4ce8-8132-e3ecf48c0545 \
    --query 'IPSet.Addresses'
}
