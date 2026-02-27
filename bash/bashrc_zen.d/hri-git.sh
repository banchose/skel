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
