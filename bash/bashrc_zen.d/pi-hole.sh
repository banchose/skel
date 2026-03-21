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
