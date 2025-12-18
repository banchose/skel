#!/usr/bin/env bash
#
set -euo pipefail

(
	apk add git tmux jq nmap bash-completion pv sed coreutils findutils nfs-utils nfs-utils-doc findutils-doc binutils binutils-doc coreutils-doc dateutils dateutils-doc htop gawk procps-ng perl step-cli the_silver_searcher the_silver_searcher-bash-completion the_silver_searcher-doc procs-bash-completion rust 7zip 7zip-doc zip unzip tshark fd ripgrep vim nano neovim curl wget aria2 socat rsync ncurses rclone iproute2 gcc make cmake gdb curl wget aria2 rclone rsync openssh nginx socat bcc py3-pip py3-pip-doc py3-pip-bash-completion py3-setuptools
	# apk add emacs-nox
	cd
	mkdir temp gitdir
	[[ -d ~/gitdir/skel ]] || git clone https://github.com/banchose/skel ~/gitdir/skel
	[[ -d ~/.config/nvim ]] || git clone https://github.com/lazyvim/starter ~/.config/nvim
)
