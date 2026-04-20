# source me

# Set the https credential username

## In the pisal repo (same org, same account)
# cd ~/hrigit/Kubernetes/pisal
# git config credential.https://github.com.username wjs04-hri

## In the banchose repo
# cd ~/gitdir/aws
# git config credential.https://github.com.username banchose

# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v git >/dev/null 2>&1 || return 0

alias gitb='git branch -vv' # show detailed branch info
alias gitr='git branch -r'  # show remote branches
alias cdskel='cd ~/gitdir/skel'
alias cdskelb='cd ~/gitdir/skel/bash/bashrc_zen.d'
alias cdzen='cd ~/gitdir/skel/bash/bashrc_zen.d'
alias cdconfigs='cd ~/gitdir/configs'
alias cdzend='cd ~/.bashrc_zen.d'

gitcheck() {
  for i in ~/gitdir/{aws,skel,configs}; do
    cd "${i}" || return 1
    git status
    cd ..
  done
}

gitroll() {
  (
    cd ~/gitdir || return 1
    for i in aws configs skel; do
      cd "$i" || return 1
      git fetch
      git status
      git pull
      cd ..
    done
  )
}

git_pull_hri() {

  cd ~/hrigit/
  for repo in ./*/; do
    if [[ -d ${repo}/.git ]]; then
      cd "${repo}"
      git s
      git fetch --prune
      git pull
    else
      echo "Skipping ${repo}"
    fi
  done

}

gitseal() {
  (
    cd ~/gitdir || return 1
    for repo in ~/gitdir/{configs,aws,skel}; do
      cd "$repo" || return 1
      echo "####################################"
      echo ""
      echo " Hitting ${repo}"
      echo ""
      echo "####################################"
      git fetch --prune
      git status
      git pull
      git status
      git add .
      git commit -m "gitseal"
      echo "pushing a seal"
      git push
      cd ..
    done
    cd ~/gitdir || return 1
    for repo in ~/gitdir/{configs,aws,skel}; do
      cd "${repo}" || return 1
      echo "####################################"
      echo ""
      echo " Hitting ${repo}"
      echo ""
      echo "####################################"
      git status
      cd ..
    done
  )
}

gitclear() {
  git credential reject <<EOF
protocol=https
host=github.com
EOF
  echo "Git credentials for github.com rejected. You'll be prompted for authentication on next Git operation."
}

gitdisablehelpers() {
  # Clear
  git config --unset-all credential.helper
}

gitcredwin() {
  gitclear
  git config --global credential.helper /mnt/c/"Program Files"/Git/mingw64/bin/git-credential-manager.exe
  # /mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe
}

gitwho() {
  git config --get user.name
  git config --get user.email
  git config --get credential.https://github.com.username
}

git_set_hri() {
  echo "Current git identity"
  gitwho
  git config user.name "wjs04-hri"
  git config user.email "william.stewart"
  git config credential.https://github.com.username wjs04-hri
  echo "--- set to hri ---"
  gitwho
}

git_set_home() {
  echo "Current git identity"
  gitwho
  git config user.name "banchose"
  git config user.email "a_gitmail@ownmail.net"
  git config credential.https://github.com.username banchose
  echo "--- set to home ---"
  gitwho
}

gitcredclear() {

  git credential-manager erase
  echo "url=https://github.com" | git credential reject
}

gitsync() {
  local gitdir=~/gitdir
  (
    cd "$gitdir" || {
      echo "Cannot cd into $gitdir"
      exit 1
    }
    local threshold
    threshold=$(date -d '1 year ago' +%s)

    for i in ./*/; do
      cd "$i" >/dev/null || continue
      echo "**********************************"
      echo "    ${PWD##*/}"
      echo "**********************************"

      if [[ -d .git ]]; then
        last=$(git log -1 --format=%ct --all 2>/dev/null)
        if [[ -n "$last" ]] && ((last < threshold)); then
          echo "STALE — skipping"
        else
          git fetch --prune &&
            git reset --hard "origin/$(git rev-parse --abbrev-ref HEAD)"
        fi
      fi
      cd ..
    done
  )
}

# gitsync() {
#
#   local gitdir=~/gitdir
#   # put in subshell to avoid changing directory
#   (
#     cd "$gitdir" || {
#       echo "Cannot cd into $gitdir"
#       exit 1
#     }
#     # the ./*/ will do just directories.  ./* will do files and directories
#     for i in ./*/; do
#       cd "$i" >/dev/null
#       echo "**********************************"
#       echo $'\t'"${PWD##*/}"
#       echo "**********************************"
#       #      [[ -d .git ]] && git fetch --prune && git status && git pull
#       last=$(git log -1 --format=%ct --all 2>/dev/null) # epoch seconds
#       threshold=$(date -d '1 year ago' +%s)
#       ((last < threshold)) && echo "STALE"
#       [[ -d .git ]] && git fetch --prune && git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
#       cd ..
#     done
#   )
#
# }

gitp() (
  # look for gitdir cd in and git
  cd ~/gitdir/configs || {
    echo "Missing gitdir"
    return 1
  }
  command -v git &>/dev/null || {
    echo "Cannot find git"
    return 1
  }
  git fetch
  git s
  git add .
  git commit -m "generic zen script"
  git push
)

git_help() {

  cat <<'EOF'
git reset --hard origin/main
git reset --hard origin/$(git rev-parse --abbrev-ref HEAD)
git log -p --follow -- path/to/file
EOF
}
