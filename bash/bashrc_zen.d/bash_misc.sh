args() {
  printf "%d args:" "$#"
  [ "$#" -eq 0 ] || printf " <%s>" "$@"
  printf '\n'
}

bnaked() {
  env -i bash --norc --noprofile
}

a_timer() {
  now=$(date '+%s')
  [ -z "$then" ] && then=$now
  echo $((now - then))
  then=$now
}

glob_to_regex() {
  local glob="$1"
  local regex=""
  local i char

  for ((i = 0; i < ${#glob}; i++)); do
    char="${glob:i:1}"
    case "${char}" in
    '*') regex+='.*' ;;
    '?') regex+='.' ;;
    '.') regex+='\.' ;;
    '[') regex+='[' ;;
    ']') regex+=']' ;;
    # Escape other regex metacharacters
    '(' | ')' | '{' | '}' | '+' | '^' | '$' | '|' | '\\')
      regex+="\\${char}"
      ;;
    *) regex+="${char}" ;;
    esac
  done

  printf '^%s$\n' "${regex}"
}
