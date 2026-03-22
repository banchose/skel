alias editinit='$EDITOR "${HOME}"/gitdir/skel/init/init-pipx.sh'

args() {
  printf "%d args:" "$#"
  [ "$#" -eq 0 ] || printf " <%s>" "$@"
  printf '\n'
}

bnaked() {
  env -i bash --norc --noprofile
}

alias editbashmisc='nvim ~/gitdir/skel/bash/bashrc_zen.d/bash_misc.sh'
alias editbashhelp='nvim ~/gitdir/skel/bash/bashrc_zen.d/bash-help.md'

bash-help() {
  local bash_help_path="${HOME}/.bashrc_zen.d/bash-help.md"
  local pager

  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 'bash-help: no usable pager found (bat/less/cat)\n'
    return 1
  fi

  if [[ ! -f "${bash_help_path}" ]]; then
    printf >&2 'bash-help: cannot find %s\n' "${bash_help_path}"
    return 1
  fi

  "${pager}" "${bash_help_path}"
}

grep-help() {
  local grep_help_path="${HOME}/.bashrc_zen.d/grep-help.md"
  local pager

  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 'grep-help: no usable pager found (bat/less/cat)\n'
    return 1
  fi

  if [[ ! -f "${grep_help_path}" ]]; then
    printf >&2 'grep-help: cannot find %s\n' "${grep_help_path}"
    return 1
  fi

  "${pager}" "${grep_help_path}"
}

bash-help-pure() {
  local purebash_help_path="${HOME}/gitdir/skel/bash/pure-bash-bible.md"
  local pager

  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 'purebash-help: no usable pager found (bat/less/cat)\n'
    return 1
  fi

  if [[ ! -f "${purebash_help_path}" ]]; then
    printf >&2 'purebash-help: cannot find %s\n' "${purebash_help_path}"
    return 1
  fi

  "${pager}" "${purebash_help_path}"
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

par2_it() {
  local input="${1:?Usage: par2_it <file_or_directory>}"

  if [[ ! -e "$input" ]]; then
    echo "Error: '$input' does not exist" >&2
    return 1
  fi

  input="${input%/}"
  local base
  base="$(basename -- "$input")"
  local archive="${base}.tar.gz.gpg"

  if [[ -e "$archive" ]]; then
    echo "Error: '$archive' already exists" >&2
    return 1
  fi

  local -
  set -o pipefail

  tar czf - -- "$input" | gpg --symmetric --compress-algo none --batch -o "$archive" || {
    echo "Error: tar/gpg pipeline failed" >&2
    rm -vf -- "$archive" 2>/dev/null
    return 1
  }

  par2 create -r5 -n7 -- "$archive" || {
    echo "Warning: par2 failed, encrypted archive still exists" >&2
    return 1
  }

  echo "Done: $archive (+ par2 files)"
}
