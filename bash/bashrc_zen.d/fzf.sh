#determines search program for fzf
type fzf &>/dev/null || return 0

if type fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --hidden --exclude ".git" --exclude "gitdir"'
elif type rg &>/dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git" "!gidir"'
elif type find &>/dev/null; then
  export FZF_DEFAULT_COMMAND='find . -type f ! -path "*git*"'
fi

alias fzfmod='find . -type f -printf "%T@ %p\n" | sort -nr | cut -d" " -f2- | fzf'

[[ -r /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/completion.bash
[[ -r /usr/share/fzf/completion.bash ]] && source /usr/share/fzf/key-bindings.bash

vf() {
  command -v fzf &>/dev/null && file="$(fzf)"
  [[ -f $file ]] && nvim "${file}"
}

vz() {
  (
    [[ -d ~/gitdir/skel/bash/bashrc_zen.d ]] || {
      echo "Missing ~/gitdir/skel/bash/bashrc_zen.d/"
      return 1
    }
    command -v fzf &>/dev/null && file="$(fzf)"
    [[ -f $file ]] && nvim "${file}"
  )
}
