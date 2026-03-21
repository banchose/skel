pihole_get_auth() {

  [[ -z ${PIHOLE_ADMIN_PASS} ]] && {
    echo "PIHOLE_ADMIN_PASS is not set"
    return 1
  }
  curl -k -X POST "https://pi.hole/api/auth" \
    --data '{"password":"'"${PIHOLE_ADMIN_PASS}"'"}'
}

pihole_get() {
  [[ -z ${PIHOLE_SID} ]] && {
    echo "PIHOLE_SID is not set"
    return 1
  }

  curl -k "https://pi.hole/api/stats/summary?sid=${PIHOLE_SID}"
}
