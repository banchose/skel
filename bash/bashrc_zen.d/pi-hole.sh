pihole_install_cert() {
  # Download package from porkbun
  # xaax.dev-ssl-bundle.zip

  BUNDLEZIP=xaax.dev-ssl-bundle.zip
  DOMCERT=domain.cert.pem
  KEY=private.key.pem
  PUBLICKEY=public.key.pem

  cd ~/Downloads
  [[ -r ./${BUNDLEZIP} ]] || {
    echo "missing ${BUNDLEZIP}"
    exit 1
  }
  unzip -- ./"${BUNDLEZIP}" || {
    echo "Error unzipping ${BUNDLEZIP}"
    exit 1
  }
  cd "${BUNDLEZIP%.*}"

  cat "${DOMCERT}" "${KEY}" >|tls.pem

  scp ./tls.pem root@ns2:/etc/pihole
}

pihole_get_auth() {

  [[ -z ${PIHOLE_ADMIN_PASS} ]] && {
    echo "PIHOLE_ADMIN_PASS is not set"
    return 1
  }
  #  curl -s -k -X POST "https://pi.hole/api/auth" \
  curl -s -X POST "https://ns2.xaax.dev/api/auth" \
    --data '{"password":"'"${PIHOLE_ADMIN_PASS}"'"}'
}

pihole_get() {
  [[ -z ${PIHOLE_SID} ]] && {
    echo "PIHOLE_SID is not set"
    return 1
  }

  curl -s "https://ns2.xaax.dev/api/stats/summary?sid=${PIHOLE_SID}"
}
