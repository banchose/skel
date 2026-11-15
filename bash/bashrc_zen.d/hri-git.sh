# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v git >/dev/null 2>&1 || return 0

gitsync-hri() {

  local gitdir=~/hrigit
  # put in subshell to avoid changing directory
  (
    cd "$gitdir" || {
      echo "Cannot cd into $gitdir"
      exit 1
    }
    # the ./*/ will do just directories.  ./* will do files and directories
    for i in ./*/; do
      cd "$i" >/dev/null
      echo "**********************************"
      echo $'\t'"${PWD##*/}"
      echo "**********************************"
      [[ -d .git ]] && git fetch --prune && git status && git pull
      cd ..
    done
  )

}
