#!/usr/bin/env bash

GitZenDir=~/gitdir/configs/.bashrc_zen.d
FromZenDir=~/gitdir/skel/bash/bashrc_zen.d
ToZenDir=~/.bashrc_zen.d

[[ -d $FromZenDir ]] || {
	echo "${zenDir} not there.  Skipping..."
	return 0
}

command -v fzf &>/dev/null || {
	echo "NO fzf. Skipping..."
	return 0
}

sky() {
	command ssh-add -l | command grep id_rsa && {
		echo "A key is already loaded."
		return 1
	}
	command pkill ssh-agent
	eval "$(ssh-agent)" && command ssh-add
}

zen_update_sync() {

	[[ -d ${GitZenDir} ]] || {
		echo "No directory: ${GitZenDir}"
		return 1
	}
	command rsync -ruv -- "${GitZenDir}/" "${FromZenDir}"
}
zen_make() {
	[[ -d $ToZenDir ]] && {
		echo "${ToZenDir} already exists"
		return 0
	}
	command mkdir -v -p -- $ToZenDir
}

zen_rm() {
	if [[ -d ${ToZenDir} ]]; then
		command rm --preserve-root=all --one-file-system -v -r -- "${ToZenDir}"
	else
		echo "Missing ${ToZenDir}"
	fi
}

zenlk() {

	[[ -d ${ToZenDir} && -d ${FromZenDir} ]] || {
		echo "Need both ${ToZenDir} and ${FromZenDir} to exist"
		return 1
	}
	Selected="$(find "${FromZenDir}" -iname "*.sh" -type f | fzf)"
	[[ -n ${Selected} ]] || {
		echo "No files selected from fzf"
		popd
		return 1
	}
	cd -- "${ToZenDir}"
	ln -s -- "${Selected}" "${ToZenDir}"
}
