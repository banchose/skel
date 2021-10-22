

# IF not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$'
set -o vi
bind '"jj":vi-movement-mode'
shopt -s histverify
shopt -s checkwinsize
shopt -s cmdhist
shopt -s complete_fullquote
shopt -u lithhist
shopt -s interactive_comments



################################
# Aliases
################################
alias l='ls -alF --color=auto'
alias v='/usr/bin/nvim'
# alias v='/usr/bin/vim'
alias g='grep -i --color=always'
