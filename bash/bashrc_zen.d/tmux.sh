tmux_get_tpm() {
	command -v git &>/dev/null || {
		echo "No git"
		return 1
	}
	[[ -d ~/.tmux/plugins/tpm ]] && {
		echo "~/.tmux/plugins/tpm/ already exists"
		return 1
	}
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}
