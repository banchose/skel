# Just a personal .bashrc that maybe renamed and then included in the real ~/.bashrc
# in ~/.bashrc: [[ -f ~/.bashrc.includeme ]] && source ~/.bashrc.includeme

# echo "${BASH_SOURCE[0]}"

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

umask 022

# Unique Bash version check
if ((BASH_VERSINFO[0] < 4)); then
  echo "You may be running an older version of Bash: ${BASH_VERSINFO[0]}."
fi

###
# SSH Agent
###

loadAgent2() {

  # This is already defined in ~/.bashrc_zen.d/ssh.sh as loadAgent
  # But good to have

  if ! pgrep -u "$USER" ssh-agent >/dev/null; then
    ssh-agent -t 1h >"$XDG_RUNTIME_DIR/ssh-agent.env"
  fi
  if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
  fi
}

# Then call it
# loadAgent2

######################################
# Set the editor and editor alias
######################################
command_exists() {
  command -v "$1" 1>&2 >/dev/null
}

if command_exists nvim 1>&2 >/dev/null; then
  export EDITOR=nvim
  alias v='nvim'
elif command_exists vim; then
  export EDITOR=vim
  alias v='vim'
elif command_exists vi; then
  export EDITOR=vi
  alias v='vi'
elif command_exists nano; then
  export EDITOR=nano
  alias v='nano'
else
  echo "NO EDITOR FOUND"
fi

export BC_ENV_ARGS=~/.bcrc
export LESS="-iMFXRj4Q"

# Since switching to set -o vi... Control D logs me out so now have to do 4 times
set -o vi
bind -m vi-command ".":yank-last-arg # or insert-last-argument
bind '"jj":vi-movement-mode'

export IGNOREEOF=4
export PS1="\[$(tput setaf 7)\][\!]\[$(tput setaf 47)\][\H]\[$(tput setaf 3)\][\u]\[$(tput setaf 8)\][\D{%F %T}]\[$(tput setaf 2)\][\w]\n\[$(tput setaf 7)\][\$?][\v]\$ \[$(tput sgr0)\]"
# Make info friendly
minfo() { info "$1" --subnodes -o - 2>/dev/null | "$PAGER"; }

# Functions
psnk() {
  ps --ppid 2 -p 2 --deselect
}

tcolors() {

  for code in {0..255}; do echo -e "\e[38;05;${code}m $code: Test"; done
}

checkip() {
  exec 3<>/dev/tcp/checkip.amazonaws.com/80
  printf "GET / HTTP/1.1\r\nHost: checkip.amazonaws.com\r\nConnection: close\r\n\r\n" >&3
  tail -n1 <&3
}

sleep1() { while :; do
  "$@"
  sleep 1
done; }

sleep5() { while :; do
  "$@"
  sleep 5
done; }

sleep10() { while :; do
  "$@"
  sleep 10
done; }

function xgetx {
  printf "%d args:" $#
  printf "<%s>" "$@"
  echo
}

ff() {
  find / -mount -iname "*$1*" -type f 2>/dev/null
}

flf() {
  find ./ -mount -iname "*$1*" -type f 2>/dev/null
}

function vr() { nvim -R "${@}"; }

## GENERAL OPTIONS ##

set -o noclobber

PROMPT_DIRTRIM=10

shopt -s globstar 2>/dev/null
shopt -s checkwinsize
shopt -s nocaseglob
shopt -s histverify
shopt -s histappend
shopt -s cmdhist
shopt -s autocd 2>/dev/null
shopt -s dirspell 2>/dev/null
shopt -s cdspell 2>/dev/null
shopt -s cdable_vars
PROMPT_COMMAND='history -a'
export HISTSIZE=50000
export HISTFILESIZE=10000
export HISTCONTROL="ignorespace:erasedups"
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history:clear"
export HISTTIMEFORMAT='%F %T '

CDPATH=".:~:"

# Allows aliases to work with sudo
# alias sudo='sudo '

alias nsps='ps -eo pid,ppid,pgid,sess,stat,tty,pidns,utsns,ipcns,mntns,netns,cmd'
alias pps='ps -eo pid,ppid,pgid,sess,stat,tty,tpgid,uname,%cpu,%mem,cmd'
alias nps='ps -N --ppid 2 -o pid,ppid,pgid,sess,stat,tty,tpgid,uname,%cpu,%mem,cmd'

# Existing
alias chown='chown --preserve-root'
alias iptables='iptables -v'
alias wget='wget -c'
alias bc='bc -l'
alias dmesg='dmesg --color=always'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias cp='cp -i -v'
alias grep='grep -i --color=auto'
alias mv='mv -i -v'
alias rm='rm -v -I --preserve-root'
alias df='df -H'
alias du='du -ch'
alias ls='ls -F -h --color=always --time-style=long-iso'
alias ag='ag --hidden --ignore gitdir'
#
#
#
alias l='ls -l -aF'
alias ll='ls -AFlSrh --color=auto --group-directories-first'
alias ltr='ls -AFltrh --color=auto'
alias lt='ls -AFlth --color=auto'
alias g='grep'
alias pg="pcre2grep -i"
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias j='jobs -l'
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

###### A directory of bash init files

# if [[ -d ${home_bashrc_directory} ]]; then
# 	echo "Running ${home_bashrc_directory} scripts"
# 	for profile in "${home_bashrc_directory:-/dev/null}/"*.sh; do
# 		echo "PROFILE-LOOP: $profile"
# 		[[ -r "$profile" ]] && . "$profile"
# 	done
# 	unset profile
# fi

# Check if Bash is running interactively
if [[ $- == *i* ]]; then
  # Check if the session is already inside tmux
  if [[ -z $TMUX ]] && command -v tmux &>/dev/null; then
    # Check if Bash is running in a TTY or a pseudoterminal (e.g., /dev/pts/*)
    if [[ "$(tty)" == /dev/tty* || "$(tty)" == /dev/pts/* ]]; then
      # Start a new tmux session or attach to an existing one
      tmux new-session
    fi
  fi
fi

# Ensure the directory variable is not empty
home_bashrc_directory=~/.bashrc_zen.d

if [[ -d "${home_bashrc_directory}" ]]; then
  echo "Running scripts in ${home_bashrc_directory}"
  for profile in "${home_bashrc_directory}/"*.sh; do
    if [[ -r "$profile" ]]; then
      echo "Sourcing: $profile"
      . "$profile"
    else
      echo "Cannot read $profile, skipping..."
    fi
  done
else
  echo "Directory ${home_bashrc_directory} does not exist."
fi
