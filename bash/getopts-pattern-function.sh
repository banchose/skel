my_func() {
  local OPTIND opt
  local verbose=0
  local output=""

  while getopts ":vo:" opt; do
    case "${opt}" in
    v) verbose=1 ;;
    o) output="${OPTARG}" ;;
    ?)
      echo "Unknown option: -${OPTARG}" >&2
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  # Remaining positional args in "$@"
  echo "verbose=${verbose} output=${output} args=$*"
}
