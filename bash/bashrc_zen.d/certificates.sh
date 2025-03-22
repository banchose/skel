getcert() {

  openssl s_client -connect star.xaax.dev:443 -showcerts </dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | openssl x509 -text -noout

}
