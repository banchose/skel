#!/usr/bin/env bash

[[ -d ~/.emacs.d/bin ]] && export PATH=~/.emacs.d/bin:"${PATH}"
alias emacs='emacsclient -c -n -a "vim"'
