#determines search program for fzf
type fzf &>/dev/null || return 0

if type fd &>/dev/null; then
	export FZF_DEFAULT_COMMAND='fd --hidden --exclude ".git" --exclude "gitdir"'
elif type rg &>/dev/null; then
	export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git" "!gidir"'
elif type find &>/dev/null; then
	export FZF_DEFAULT_COMMAND='find . -type f ! -path "*git*"'
fi
