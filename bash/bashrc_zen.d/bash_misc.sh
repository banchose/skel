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
