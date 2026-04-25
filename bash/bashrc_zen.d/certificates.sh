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
# openssl x509 -in /var/etc/cert.crt -noout -text
# echo | openssl s_client -connect example.org:443 2>/dev/null | openssl x509 -noout -dates
# openssl storeutl -noout -text -certs bundle.crt # all certs in a bundle
# openssl rsa -in ./znc-nick.pem -pubout
# openssl rand -base64 <length>
# openssl dhparam -out dhparam.pem 2048
# openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -sha256 -days 365
# openssl base64 -d < ./somefile.b64o
# openssl s_client -crlf \
#   -connect www.feistyduck.com:443 \
#   -servername www.feistyduck.com
#
#

update_jellyfin_cert() {

  openssl pkcs12 -export -out jellyfin.pfx -inkey private.key.pem -in domain.cert.pem &&
    scp ./jellyfin.pfx star:/apps/jellyfin/config
}

cert_get_cn() {

  local AHOST
  AHOST="${1}"

  openssl s_client -connect "${AHOST}":443 -showcerts </dev/null | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | openssl x509 -text -noout | grep 'CN:'

}
cert_get() {
  local host="${1:-star.xaax.dev}"
  local port="${2:-443}"

  # Simple input sanitization: allow only valid hostname characters
  # Hostnames: alphanumeric, dots, hyphens; ports: digits only
  if [[ ! $host =~ ^[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?$ ]]; then
    printf 'Error: Invalid hostname format: %s\n' "$host" >&2
    return 1
  fi

  if [[ ! $port =~ ^[0-9]+$ ]] || ((port < 1 || port > 65535)); then
    printf 'Error: Invalid port: %s\n' "$port" >&2
    return 1
  fi

  openssl s_client -connect "${host}:${port}" -showcerts </dev/null 2>/dev/null |
    sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' |
    openssl x509 -text -noout
}

cert_make_self_signed_CA() {
  openssl req -x509 -newkey ed25519 \
    -keyout ca.key -out ca.crt -days 3650 -nodes \
    -subj "/CN=My Local Root CA" \
    -addext "basicConstraints=critical,CA:TRUE" \
    -addext "keyUsage=critical,keyCertSign,cRLSign" &&
    openssl x509 -in ca.crt -noout -text | grep -A1 "Issuer:\|Subject:\|Public Key Algorithm\|Basic Constraints\|Key Usage"
}

cert_make_server_cert() {
  # if you need the ca
  # mkdir ~/socat-ca && cd ~/socat-ca

  # openssl req -x509 -newkey ed25519 \
  # -keyout ca.key -out ca.crt -days 3650 -nodes \
  # -subj "/CN=socat playground Root CA" \
  # -addext "basicConstraints=critical,CA:TRUE" \
  # -addext "keyUsage=critical,keyCertSign,cRLSign"
  #
  cat >server.ext <<'EOF'
basicConstraints = CA:FALSE
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth
subjectAltName = DNS:localhost, IP:127.0.0.1
EOF
  # Server key + CSR
  openssl req -new -newkey ed25519 -keyout server.key -out server.csr \
    -nodes -subj "/CN=localhost"

  # CA signs it
  openssl x509 -req -in server.csr \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -out server.crt -days 365 \
    -extfile server.ext
}

cert_socat_listen_ssl() {
  cat >/tmp/respond.sh <<'EOF'
#!/bin/sh
printf 'HTTP/1.1 200 OK\r\nContent-Length: 3\r\n\r\nhi\n'
EOF
  chmod +x /tmp/respond.sh

  socat OPENSSL-LISTEN:4443,cert=server.pem,cafile=ca.crt,verify=0,reuseaddr,fork \
    EXEC:/tmp/respond.sh
}

cert_make_all() {

  (
    certdir="${HOME}/temp/cert-$(date '+%s')"
    mkdir "${certdir}"
    cd "${certdir}"
    cert_make_self_signed_CA
    cert_make_server_cert
  )

}
