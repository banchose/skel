getcert() {

  local AHOST
  AHOST="${1}"

  openssl s_client -connect "${AHOST}":443 -showcerts </dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | openssl x509 -text -noout

}
