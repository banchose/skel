#!/usr/bin/env bash

# basically, neovim stores its configuration in ~/.config/nvim
# This will clone other Neovim distros into their own
# ~/.config directroy
# You get Neovim to point to that as its new home by
# setting NVIM_APPNAME
# So if astronvim is in ~/.config/astronvim because you git cloned
# it there. then `NVIM_APPNAME="astronvim" nvim` uses XDG

get-astro() {

	local name=astronvim
	local configdir=~/.config/"${name}"
	local sharedir=~/.local/share/"${name}"

	[[ -d $configdir ]] && rm -rfv -- "$configdir"
	[[ -d $sharedir ]] && rm -rfv -- "$sharedir"

	git clone --depth 1 "https://github.com/${configdir##*/}/${configdir##*/}" "$configdir"
}

get-nvchad() {

	local name=nvchad
	local configdir=~/.config/"${name}"
	local sharedir=~/.local/share/"${name}"

	[[ -d $configdir ]] && rm -rfv -- "$configdir"
	[[ -d $sharedir ]] && rm -rfv -- "$sharedir"

	git clone --depth 1 "https://github.com/${configdir##*/}/${configdir##*/}" "$configdir"
}

get-lazy() {

	local name=lazyvim
	local configdir=~/.config/"${name}"
	local sharedir=~/.local/share/"${name}"

	[[ -d $configdir ]] && rm -rfv -- "$configdir"
	[[ -d $sharedir ]] && rm -rfv -- "$sharedir"

	git clone --depth 1 "https://github.com/lazyvim/starter" "$configdir"
}

get-space() {
	# Hard coded git
	local name=spacevim
	local configdir=~/.config/"${name}"
	local sharedir=~/.local/share/"${name}"

	[[ -d $configdir ]] && rm -rfv -- "$configdir"
	[[ -d $sharedir ]] && rm -rfv -- "$sharedir"

	git clone --depth 1 "https://gitlab.com/${configdir##*/}/${configdir##*/}" "${configdir,,}"
}

get-default() {
	# Hard coded git
	local name=nvim
	local configdir=~/.config/"${name}"
	local sharedir=~/.local/share/"${name}"

	[[ -d $configdir ]] && rm -rfv -- "$configdir"
	[[ -d $sharedir ]] && rm -rfv -- "$sharedir"

	git clone --depth 1 "https://github.com/lazyvim/starter" "$configdir"
}

nvims() {

	# This just gets a string from fzf and that sting must match
	# a directory in ~/.config
	# That directory should have the git repo of the nvim disto
	# So it may expect ~/.config/astronvim if you pick "astronvim" from the menu
	# Then set the handy NVIM_APPNAME=astronvim which must be name under ~/.config
	items=("default" "kickstart.nvim" "LazyVim" "NvChad" "AstroNvim" "SpaceVim")

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
