#!/usr/bin/env bash

[[ -f ~/.bashrc ]] && cp -v -- ~/.bashrc{,.orig}
[[ -f ~/.inputrc ]] && cp -v -- ~/.inputrc{,.orig}
[[ -f ~/.tmux.conf ]] && cp -v -- ~/.tmux.conf{,.orig}

cp -v -- ./.bashrc ~/
cp -v -- ./.inputrc ~/
cp -v -- ./.tmux.conf ~/
