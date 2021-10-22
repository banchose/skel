

# IF not running interactively, don't do anything
[[ $- != *i* ]] && return

################################
# Bash 
################################
# PROMPT_DIRTRIM=10
PROMPT_COMMAND='history -a'
CDPATH='.:~:'
export HISTCONTROL='ignorespace:erasedups'
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
export HISTTIMEFORMAT='%F %T '
###
# vi mode
###
set -o vi
bind '"jj":vi-movement-mode'
bind -m vi-command ".":yank-last-arg # or insert-last-argument
###
# bash options
###
set -o noclobber
shopt -s histverify
shopt -s checkwinsize
shopt -s cmdhist
# shopt -s complete_fullquote
shopt -u lithist
shopt -s interactive_comments
shopt -s globstar
shopt -s nocaseglob
shopt -s autocd 2>/dev/null
shopt -s dirspell 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s cdable_vars



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
elif command -v vim >/dev/null 2>&1
then
    export EDITOR='/usr/bin/vim'
 else
     export EDITOR='/usr/bin/vi'
fi

################################
# Functions
################################
minfo() { info "$1" --subnodes -o - 2> /dev/null | "$PAGER"; }

# Find processes that are not of the kernel
psnk () {
    ps --ppid 2 -p 2 --deselect
}

# Print out the number of colors in the terminal
tcolors () {

    for code in {0..255}; do echo -e "\e[38;05;${code}m $code: Test"; done
}


function sleep1 () while :; do "$@"; sleep 1; done
function sleep5 () while :; do "$@"; sleep 5; done
function sleep10 () while :; do "$@"; sleep 10; done


# Little function to show parameter expansions
function xgetx { printf "%d args:" $#; printf "<%s>" "$@"; echo; }

# Handy little find function
ff () {
    find / -mount -iname "*$1*" -type f 2>/dev/null
}

flf () {
    find ./ -mount -iname "*$1*" -type f 2>/dev/null
}

# Function to generate a bash script template
mksh()
{

    EDR="${EDITOR:-vim}"
    RANNAME="$(cat /dev/urandom | tr -dc "[:alpha:]" | head -c 4)"

    SCRIPTNAME="${1:-$RANNAME-mksh.sh}"

    touch "$SCRIPTNAME" &&
        chmod --preserve-root +x "$SCRIPTNAME" &&
        echo '#!/usr/bin/env bash' >> "$SCRIPTNAME" &&
        echo '' >> "$SCRIPTNAME" &&
        echo 'set -euo pipefail' >> "$SCRIPTNAME" &&
        "$EDR" "$SCRIPTNAME"
}

cdl() { cd "$@"; ls; }

function vr () { nvim -R "${@}"; }


################################
# Aliases
################################
alias l='ls -alF --color=auto'
alias v="$EDITOR"
# alias v='/usr/bin/vim'
alias g='grep -i --color=always'
###
# For Ubuntu
###
[[ $(</etc/os-release) =~ ID=ubuntu ]] && [[ -x /usr/bin/batcat ]] && alias bat='/usr/bin/batcat'
# alias vim="nvim"
# [[ -x $(command -v nvim) ]] && alias v="$(command -v nvim)"
alias vg='nvim-qt 2>/dev/null'
alias ls='ls -F -h --color=always'
alias l='ls -l -a'
alias ll='ls -h -l -a -F --color=always'
alias lss='ls -AFlSrh --color=auto --group-directories-first'
alias ltr='ls -AFltrh --color=auto'
alias lt='ls -AFlth --color=auto'
alias g='grep -i --color=auto'
alias grep='grep -i --color=auto'
###
# Safety
###
alias cp='cp -i -v'
alias mv='mv -i -v'
alias pg="pcre2grep -i"
alias cpu='htop -s PERCENT_CPU'
alias mem='htop -s PERCENT_MEM'
alias path='echo -e ${PATH//:/\\n}'
alias dmesg='dmesg --color=always'
alias now='date +"%T"'
alias cd..='cd ..'
alias h='history'
alias j='jobs -l'
alias mnt='mount | column -t'
alias bc='bc -l'
alias mkdir='mkdir -pv'
alias wget='wget -c'
alias acurl='curl -s -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0"'
## shortcut  for iptables and pass it via sudo#
alias ipt='sudo /sbin/iptables'
# display all rules #
alias iptlist='sudo /sbin/iptables -L -n -v --line-numbers'
alias iptlistin='sudo /sbin/iptables -L INPUT -n -v --line-numbers'
alias iptlistout='sudo /sbin/iptables -L OUTPUT -n -v --line-numbers'
alias iptlistfw='sudo /sbin/iptables -L FORWARD -n -v --line-numbers'
alias firewall=iptlist
# Safety
alias rm='rm -v -I --preserve-root'
# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias df='df -H'
alias du='du -ch'
## pass options to free ##
alias meminfo='free -m -l -t'
# share history between terminal sessions
alias hh='history -a && history -n'
# man systemd.time
# journalctl
# 0:emerg, 1:alert, 2:crit, 3:err, 4:warning, 5:notice, 6:info, 7:debug
alias j5m='journalctl --since "5 min ago"'
alias j1h='journalctl --since "1 hour ago"'
alias j5h='journalctl --since "5 hour ago"'
alias jd='journalctl --since "1 day ago"'
alias jb='journalctl -b'
alias ju='journalctl -u'
alias je='journalctl -p "emerg..err"'
alias jw='journalctl -p "emerg..warning"'
alias jn='journalctl -p "emerg..notice"'
alias jbe='journalctl -p "emerg..err" -b'
alias jbw='journalctl -p "emerg..warning" -b'
alias jbn='journalctl -p "emerg..notice" -b'
alias jlb='journalctl --list-boots'
# A load average of multi cpu system
alias loada='cat /proc/loadavg | cut -c 1-4 | echo "scale=2; ($(</dev/stdin)/`nproc`)*100" | bc -l'
## Get server cpu info ##
alias cpuinfo='lscpu'
alias xlsblk='lsblk -o name,mountpoint,fstype,size,fsused,pttype,model,vendor,serial,uuid,partuuid'
