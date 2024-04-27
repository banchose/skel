#!/usr/bin/env bash

WIPE_NVIM() {

	# required
	[[ -d ~/.config/nvim ]] || {
		echo "~/.config/nvim already gone"
		return 0
	}
	mv -v -- ~/.config/nvim{,.bak}

	# optional but recommended
	mv -v -- ~/.local/share/nvim{,.bak}
	mv -v -- ~/.local/state/nvim{,.bak}
	mv -v -- ~/.cache/nvim{,.bak}
}
