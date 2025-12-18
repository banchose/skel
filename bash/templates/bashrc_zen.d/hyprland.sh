#!/usr/bin/env bash
#
#

conplug=~/.config/nvim/lua/plugin/copilot.lua
gitplug=~/gitdir/configs/nvim/lua/plugins/copilot.lua

if [[ -L $conplug ]]; then
	print "%s\n" "Found Copilot sym linked"
	rm -v -- "$conplug"
elif [[ -f $gitplug ]]; then
	print "%s\n" "Creating Copilot sym link"
	ln -v -s -- "$gitplug" "$conplug"
fi
