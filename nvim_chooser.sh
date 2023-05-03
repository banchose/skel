#!/usr/bin/env bash

set -uo pipefail

# basically, neovim stores its configuration in ~/.config/nvim
# This will clone other Neovim distros into their own
# ~/.config directroy
# You get Neovim to point to that as its new home by
# setting NVIM_APPNAME
# So if astronvim is in ~/.config/astronvim because you git cloned
# it there. then `NVIM_APPNAME="astronvim" nvim` uses XDG

get-astro() {

	local configdir=~/.config/astronvim

	[[ -d $configdir ]] && {
		echo "$configdir exists"
		return 0
	}
	git clone --depth 1 "https://github.com/${configdir##*/}/${configdir##*/}" "$configdir"
	rm -rfv -- "$configdir/.git"
}

get-nvchad() {

	local configdir=~/.config/nvchad

	[[ -d $configdir ]] && {
		echo "$configdir exists"
		return 0
	}
	git clone --depth 1 "https://github.com/${configdir##*/}/${configdir##*/}" "$configdir"
	rm -rfv -- "$configdir/.git"
}

# Odd ball - starter
get-lazy() {

	local configdir=~/.config/lazyvim

	[[ -d $configdir ]] && {
		echo "$configdir exists"
		return 0
	}
	git clone --depth 1 "https://github.com/${configdir##*/}/starter" "$configdir"
	rm -rfv -- "$configdir/.git"
}

nvims() {

	# This just gets a string from fzf and that sting must match
	# a directory in ~/.config
	# That directory should have the git repo of the nvim disto
	# So it may expect ~/.config/astronvim if you pick "astronvim" from the menu
	# Then set the handy NVIM_APPNAME=astronvim which must be name under ~/.config
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
