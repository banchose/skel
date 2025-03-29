# When pasting certificates into a text box (such as in a control panel or configuration interface):
#
# 1. Place your end-entity (leaf) certificate at the top/first
# 2. Then place the intermediate certificate(s) below it
#
# Each certificate will have its own BEGIN and END delimiters:
#
# ```
# -----BEGIN CERTIFICATE-----
# (your end-entity certificate content)
# -----END CERTIFICATE-----
# -----BEGIN CERTIFICATE-----
# (intermediate certificate content)
# -----END CERTIFICATE-----
# ```
#
# The system reading this format will understand that these are separate certificates in the chain. The order matters - your certificate must come first, followed by the intermediate certificate(s).
#

getcert() {

  local AHOST
  AHOST="${1}"

  openssl s_client -connect "${AHOST}":443 -showcerts </dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | openssl x509 -text -noout

}
