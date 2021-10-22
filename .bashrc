

# IF not running interactively, don't do anything
[[ $- != *i* ]] && return

################################
# Bash 
################################
set -o vi
bind '"jj":vi-movement-mode'
shopt -s histverify
shopt -s checkwinsize
shopt -s cmdhist
shopt -s complete_fullquote
shopt -u lithhist
shopt -s interactive_comments



export LESS='-iMFXRj4Q'
# -i, --ignore-case
# -M, --LONG-PROMPT
# -F, --quit-if-one-screen
# -X, --no-init (screen)
# -R, --raw-control-chars
# -jn, --jump-target=n (specify line on screen pos)
# -a, --search-skip-screen
# -Q, --quiet or --silent (bell off)
export IGNOREEOF=4

################################
# Prompt PS1
################################
# PS1='[\u@\h \W]\$'
export PS1="\[$(tput setaf 7)\][\!]\[$(tput setaf 47)\][\H]\[$(tput setaf 3)\][\u]\[$(tput setaf 8)\][\D{%F %T}]\[$(tput setaf 2)\][\w]\n\[$(tput setaf 7)\][\$?][\v]\$ \[$(tput sgr0)\]"


################################
# Set EDITOR
################################
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
