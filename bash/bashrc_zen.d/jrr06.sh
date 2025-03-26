INGRESS=ingo.healthresearch.org

tpisalapi() {
  nslookup "${INGRESS}" || {
    echo nslookup failed for "${INGRESS}"
    return 1
  }
  ret="$(curl -s https://"${INGRESS}"/pisalapi/api/v1/app/version)" || {
    echo ""
    echo ""
    echo "curl failed for ${INGRESS}"
    echo ""
    echo ""
    return 1
  }

  if command -v jq &>/dev/null; then
    echo "${ret}" | jq '.'
  else
    echo "${ret}"
  fi
}
