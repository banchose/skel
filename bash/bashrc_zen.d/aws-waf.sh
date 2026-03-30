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
