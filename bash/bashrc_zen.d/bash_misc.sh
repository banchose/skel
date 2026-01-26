args() {
  printf "%d args:" "$#"
  [ "$#" -eq 0 ] || printf " <%s>" "$@"
  printf '\n'
}
