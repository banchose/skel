# slash after will dump the contents of the directory in the destination
# sync youtube-down

function wood-sync() {
  local SyncDest=star
  ping -q -w 2 -l 2 -c 1 "${SyncDest}" &>/dev/null || {
    echo "${SyncDest} not responding"
    return 1
  }
  rsync -rvptgle ssh /home/una/y/youtube-down star.xaax.dev:/sync/"${HOSTNAME}"
  rsync --del -rvptgle ssh /home/una/gitdir star.xaax.dev:/sync/"${HOSTNAME}"
  rsync --del -rvptgle ssh /home/una/Dropbox star.xaax.dev:/sync/"${HOSTNAME}"
  rsync --del -rvptgle ssh /home/una/.config/ star.xaax.dev:/sync/"${HOSTNAME}"/dotconfig

}
