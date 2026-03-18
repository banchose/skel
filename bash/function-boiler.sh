my_function() {
  local required_arg="${1:-}"
  local second_arg="${2:-}"
  local third_arg="${3:-}"

  # --- Validate required args ---
  [[ -z "$required_arg" ]] && {
    printf >&2 'Error: required_arg is missing\n'
    return 1
  }

  # ... your logic here ...
}
