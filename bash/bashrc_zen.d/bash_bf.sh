bf_extract() {
  # Usage: extract file "opening marker" "closing marker"
  while IFS=$'\n' read -r line; do
    [[ $extract && $line != "$3" ]] &&
      printf '%s\n' "$line"

    [[ $line == "$2" ]] && extract=1
    [[ $line == "$3" ]] && extract=
  done <"$1"
}

bf_trim_string() {
  # Usage: trim_string "   example   string    "
  : "${1#"${1%%[![:space:]]*}"}"
  : "${_%"${_##*[![:space:]]}"}"
  printf '%s\n' "$_"
}

# shellcheck disable=SC2086,SC2048
bf_trim_all() {
  # Usage: trim_all "   example   string    "
  set -f
  set -- $*
  printf '%s\n' "$*"
  set +f
}

bf_regex() {
  # Usage: regex "string" "regex"
  [[ $1 =~ $2 ]] && printf '%s\n' "${BASH_REMATCH[1]}"
}

bf_split() {
  # Usage: split "string" "delimiter"
  IFS=$'\n' read -d "" -ra arr <<<"${1//$2/$'\n'}"
  printf '%s\n' "${arr[@]}"
}

bf_lower() {
  # Usage: lower "string"
  printf '%s\n' "${1,,}"
}

bf_upper() {
  # Usage: upper "string"
  printf '%s\n' "${1^^}"
}

bf_trim_quotes() {
  # Usage: trim_quotes "string"
  : "${1//\'/}"
  printf '%s\n' "${_//\"/}"
}

bf_strip_all() {
  # Usage: strip_all "string" "pattern"
  printf '%s\n' "${1//$2/}"
}

bf_strip() {
  # Usage: strip "string" "pattern"
  printf '%s\n' "${1/$2/}"
}

bf_remove_array_dups() {
  # Usage: remove_array_dups "array"
  declare -A tmp_array

  for i in "$@"; do
    [[ $i ]] && IFS=" " tmp_array["${i:- }"]=1
  done

  printf '%s\n' "${!tmp_array[@]}"
}

bf_random_array_element() {
  # Usage: random_array_element "array"
  local arr=("$@")
  printf '%s\n' "${arr[RANDOM % $#]}"
}

bf_dirname() {
  # Usage: dirname "path"
  local tmp=${1:-.}

  [[ $tmp != *[!/]* ]] && {
    printf '/\n'
    return
  }

  tmp=${tmp%%"${tmp##*[!/]}"}

  [[ $tmp != */* ]] && {
    printf '.\n'
    return
  }

  tmp=${tmp%/*}
  tmp=${tmp%%"${tmp##*[!/]}"}

  printf '%s\n' "${tmp:-/}"
}

bf_basename() {
  # Usage: basename "path" ["suffix"]
  local tmp

  tmp=${1%"${1##*[!/]}"}
  tmp=${tmp##*/}
  tmp=${tmp%"${2/"$tmp"/}"}

  printf '%s\n' "${tmp:-/}"
}

bf_get_term_size() {
  # Usage: get_term_size

  # (:;:) is a micro sleep to ensure the variables are
  # exported immediately.
  shopt -s checkwinsize
  (
    :
    :
  )
  printf '%s\n' "$LINES $COLUMNS"
}

bf_uuid() {
  # Usage: uuid
  C="89ab"

  for ((N = 0; N < 16; ++N)); do
    B="$((RANDOM % 256))"

    case "$N" in
    6) printf '4%x' "$((B % 16))" ;;
    8) printf '%c%x' "${C:$RANDOM%${#C}:1}" "$((B % 16))" ;;

    3 | 5 | 7 | 9)
      printf '%02x-' "$B"
      ;;

    *)
      printf '%02x' "$B"
      ;;
    esac
  done

  printf '\n'
}

bf_get_functions() {
  # Usage: get_functions
  IFS=$'\n' read -d "" -ra functions < <(declare -F)
  printf '%s\n' "${functions[@]//declare -f /}"
}

#### Name variable based on another variable
# var="world"
# declare "hello_$var=value"
# printf '%s\n' "$hello_world"

# lstrip() {
#     # Usage: lstrip "string" "pattern"
#     printf '%s\n' "${1##$2}"
# }
#
# rstrip() {
#     # Usage: rstrip "string" "pattern"
#     printf '%s\n' "${1%%$2}"
# }
#
# if [[ $var == sub_string* ]]; then
#     printf '%s\n' "var starts with sub_string."
# fi
#
# # Inverse (var does not start with sub_string).
# if [[ $var != sub_string* ]]; then
#     printf '%s\n' "var does not start with sub_string."
# fi
