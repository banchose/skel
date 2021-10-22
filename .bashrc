

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

# Set the editor
if command -v nvim >/dev/null 2>&1
then
    export EDITOR='/usr/bin/nvim'
elsif command -v vim >/dev/null 2>&1
then
    export EDITOR='/usr/bin/vim'
 else
     export EDITOR='/usr/bin/vi'
fi

################################
# Aliases
################################
alias l='ls -alF --color=auto'
alias v="$EDITOR"
# alias v='/usr/bin/vim'
alias g='grep -i --color=always'
