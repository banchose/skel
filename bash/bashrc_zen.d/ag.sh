# source me

agx() {
  local searchpat=${1:?Missing search parameter}
  ag --ignore-dir ".cache" --ignore '*.min.js' --ignore '*.pack.js' --ignore-dir "\.config" --ignore-dir 'gitdir' -t --smart-case --hidden "$searchpat"
}

#
# In .agignore
# *.min.js
# *.pack.js
# *.svg
# node_modules/
