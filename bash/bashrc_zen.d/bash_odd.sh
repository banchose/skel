# source me

bnaked() {
  env -i bash --norc --noprofile
}

a_timer() {
  now=$(date '+%s')
  [ -z "$then" ] && then=$now
  echo $((now - then))
  then=$now
}
