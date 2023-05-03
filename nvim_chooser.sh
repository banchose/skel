#!/usr/bin/env bash

set -uo pipefail

# basically, neovim stores its configuration in ~/.config/nvim
# This will clone other Neovim distros into their own
# ~/.config directroy
# You get Neovim to point to that as its new home by
# setting NVIM_APPNAME
# So if astronvim is in ~/.config/astronvim because you git cloned
# it there. then set NVIM_APPNAME="astronvim"  uses XDG

get-astro() {

	local configdir=~/.config/astronvim

	[[ -d $configdir ]] && {
		echo "$configdir exists"
		return 0
	}
	git clone --depth 1 "https://github.com/${configdir##*/}/${configdir##*/}" "$configdir"
}

get-nvchad() {

	local configdir=~/.config/nvchad

	[[ -d $configdir ]] && {
		echo "$configdir exists"
		return 0
	}
	git clone --depth 1 "https://github.com/${configdir##*/}/${configdir##*/}" "$configdir"
}

# Odd ball - starter
get-lazy() {

	local configdir=~/.config/lazyvim

	[[ -d $configdir ]] && {
		echo "$configdir exists"
		return 0
	}
	git clone --depth 1 "https://github.com/${configdir##*/}/starter" "$configdir"
}

nvims() {
	items=("default" "kickstart" "LazyVim" "NvChad" "AstroNvim")

	config=$(printf "%s\n" "${items[@]}" | fzf --prompt="Neovim Config >> " --height=50% --layout=reverse --border --exit-0)

	# Avoid case confusion caused by presentation
	# make sane
	items=("${items[@],,}")
	config="${config,,}"

	if [[ -z $config ]]; then
		echo "Nothing selected"
		retrun 0
	elif [[ $config == "default" ]]; then
		config=""
	fi

	NVIM_APPNAME="$config" nvim "$@"
}
