alias editinit='$EDITOR "${HOME}"/gitdir/skel/init/init-pipx.sh'

args() {
  printf "%d args:" "$#"
  [ "$#" -eq 0 ] || printf " <%s>" "$@"
  printf '\n'
}

bnaked() {
  env -i bash --norc --noprofile
}

#
# find symlinks
# find /path/to/dir -xtype l -ok rm {} \;
#

alias editbashmisc='nvim ~/gitdir/skel/bash/bashrc_zen.d/bash_misc.sh'
alias editbashhelp='nvim ~/gitdir/skel/bash/bashrc_zen.d/bash-help.md'

_show_help_file() {
  local label="${1:?}" path="${2:?}"
  local pager
  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 '%s: no usable pager found (bat/less/cat)\n' "${label}"
    return 1
  fi
  if [[ ! -f "${path}" ]]; then
    printf >&2 '%s: cannot find %s\n' "${label}" "${path}"
    return 1
  fi
  "${pager}" "${path}"
}

bash-help() { _show_help_file bash-help "${HOME}/.bashrc_zen.d/bash-help.md"; }
grep-help() { _show_help_file grep-help "${HOME}/.bashrc_zen.d/grep-help.md"; }
bash-help-pure() { _show_help_file bash-help-pure "${HOME}/gitdir/skel/bash/pure-bash-bible.md"; }

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

  if [[ ! -e "${input}" ]]; then
    printf >&2 'Error: %s does not exist\n' "${input}"
    return 1
  fi

  input="${input%/}"
  local base="${input##*/}"
  local archive="${base}.tar.gz.gpg"

  if [[ -e "${archive}" ]]; then
    printf >&2 'Error: %s already exists\n' "${archive}"
    return 1
  fi

  local -
  set -o pipefail

  tar czf - -- "${input}" |
    gpg --symmetric --compress-algo none \
      --pinentry-mode loopback \
      -o "${archive}" ||
    {
      printf >&2 'Error: tar/gpg pipeline failed\n'
      rm -f -- "${archive}" 2>/dev/null
      return 1
    }

  par2 create -r5 "${archive}" || {
    printf >&2 'Warning: par2 failed, encrypted archive still exists\n'
    return 1
  }

  printf 'Done: %s (+ par2 files)\n' "${archive}"
}

par2_restore() {
  local archive="${1:?Usage: par2_restore <file.tar.gz.gpg>}"
  if [[ ! -e "${archive}" ]]; then
    printf 'Error: %s does not exist\n' "${archive}" 1>&2
    return 1
  fi

  local -
  set -o pipefail

  # Repair if par2 files are present
  local par2file="${archive}.par2"
  if [[ -e "${par2file}" ]]; then
    par2 repair "${par2file}" || {
      printf 'Error: par2 repair failed\n' 1>&2
      return 1
    }
  fi

  gpg --pinentry-mode loopback -d -- "${archive}" | tar xzf - || {
    printf 'Error: gpg/tar pipeline failed\n' 1>&2
    return 1
  }

  printf 'Done: extracted from %s\n' "${archive}"
}
