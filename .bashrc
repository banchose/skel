# Just a personal .bashrc that maybe renamed and then included in the real ~/.bashrc
# in ~/.bashrc: [[ -f ~/.bashrc.includeme ]] && source ~/.bashrc.includeme

echo "${BASH_SOURCE[0]}"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

umask 022


# Unique Bash version check
if ((BASH_VERSINFO[0] < 4))
then
  echo "You may be running an older version of Bash: ${BASH_VERSINFO[0]}."
fi


# export EDITOR="nvim"
export EDITOR="vim"
export BC_ENV_ARGS=~/.bcrc
export LESS="-iMFXRj4Q"

# Since switching to set -o vi... Control D logs me out so now have to do 4 times
set -o vi
bind -m vi-command ".":yank-last-arg # or insert-last-argument
bind '"jj":vi-movement-mode'

export IGNOREEOF=4
export PS1="\[$(tput setaf 7)\][\!]\[$(tput setaf 47)\][\H]\[$(tput setaf 3)\][\u]\[$(tput setaf 8)\][\D{%F %T}]\[$(tput setaf 2)\][\w]\n\[$(tput setaf 7)\][\$?][\v]\$ \[$(tput sgr0)\]"
# Make info friendly

includeme()
{
   # if [[ -f ~/.bashrc
   echo "hello"
   [[ -f ~/.bashrc.orig ]] || cp ~/.bashrc{,.orig}
   echo "source ~/.bashrc.includeme" >> ~/.bashrc
}

minfo() { info "$1" --subnodes -o - 2> /dev/null | "$PAGER"; }

# Functions
psnk () {
    ps --ppid 2 -p 2 --deselect
}

tcolors () {

    for code in {0..255}; do echo -e "\e[38;05;${code}m $code: Test"; done
}


sleep1 () while :; do "$@"; sleep 1; done
sleep5 () while :; do "$@"; sleep 5; done
sleep10 () while :; do "$@"; sleep 10; done


function xgetx { printf "%d args:" $#; printf "<%s>" "$@"; echo; }

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


function vr () { nvim -R "${@}"; }

## GENERAL OPTIONS ##

set -o noclobber


PROMPT_DIRTRIM=10

shopt -s globstar 2> /dev/null
shopt -s checkwinsize
shopt -s nocaseglob;
shopt -s histverify
shopt -s histappend
shopt -s cmdhist
shopt -s autocd 2> /dev/null
shopt -s dirspell 2> /dev/null
shopt -s cdspell 2> /dev/null
shopt -s cdable_vars
PROMPT_COMMAND='history -a'
export HISTSIZE=50000
export HISTFILESIZE=10000
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
export HISTTIMEFORMAT='%F %T '


CDPATH=".:~:"


######################################
#
# alias
#
#####################################

######################################
# Safety
######################################

######################################
# For ps
######################################
alias nsps='ps -eo pid,ppid,pgid,sess,stat,tty,pidns,utsns,ipcns,mntns,netns,cmd'
alias pps='ps -eo pid,ppid,pgid,sess,stat,tty,tpgid,uname,%cpu,%mem,cmd'
alias nps='ps -N --ppid 2 -o pid,ppid,pgid,sess,stat,tty,tpgid,uname,%cpu,%mem,cmd'



# alias vim="nvim"
[[ -x $(command -v nvim) ]] && alias v="$(command -v nvim)"
alias ls='ls -F -h --color=always --time-style=long-iso'
alias l='ls -l -aF'
alias ll='ls -AFlSrh --color=auto --group-directories-first'
alias ltr='ls -AFltrh --color=auto'
alias lt='ls -AFlth --color=auto'
alias g='grep -i --color=auto'
alias grep='grep -i --color=auto'
alias cp='cp -i -v'
alias mv='mv -i -v'
alias rm='rm -v -I --preserve-root'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias pg="pcre2grep -i"
alias path='echo -e ${PATH//:/\\n}'
alias dmesg='dmesg --color=always'
alias df='df -H'
alias du='du -ch'
alias now='date +"%T"'
alias j='jobs -l'
alias bc='bc -l'
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
## pass options to free ##
alias meminfo='free -m -l -t'
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
alias cpuinfo='lscpu'
alias xlsblk='lsblk -o name,mountpoint,fstype,size,fsused,pttype,model,vendor,serial,uuid,partuuid'
