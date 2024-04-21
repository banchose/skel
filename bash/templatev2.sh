#!/usr/bin/env bash
#

set -uo pipefail

set -x # debug

# Init option
Color_off='\033[0m' # Text Reset

# terminal color template
# Regular Colors
Black='\033[0;30m'  # Black
Red='\033[0;31m'    # Red
Green='\033[0;32m'  # Green
Yellow='\033[0;33m' # Yellow
Blue='\033[0;34m'   # Blue
Purple='\033[0;35m' # Purple
Cyan='\033[0;36m'   # Cyan
White='\033[0;37m'  # White

# Bold
BBlack='\033[1;30m'  # Black
BRed='\033[1;31m'    # Red
BGreen='\033[1;32m'  # Green
BYellow='\033[1;33m' # Yellow
BBlue='\033[1;34m'   # Blue
BPurple='\033[1;35m' # Purple
BCyan='\033[1;36m'   # Cyan
BWhite='\033[1;37m'  # White

# High Intensity
IBlack='\033[0;90m'  # Black
IRed='\033[0;91m'    # Red
IGreen='\033[0;92m'  # Green
IYellow='\033[0;93m' # Yellow
IBlue='\033[0;94m'   # Blue
IPurple='\033[0;95m' # Purple
ICyan='\033[0;96m'   # Cyan
IWhite='\033[0;97m'  # White

# Bold High Intensity
BIBlack='\033[1;90m'  # Black
BIRed='\033[1;91m'    # Red
BIGreen='\033[1;92m'  # Green
BIYellow='\033[1;93m' # Yellow
BIBlue='\033[1;94m'   # Blue
BIPurple='\033[1;95m' # Purple
BICyan='\033[1;96m'   # Cyan
BIWhite='\033[1;97m'  # White

#System name
System="$(uname -s)"

# need_cmd
need_cmd() {
	command -v -- "$1" &>/dev/null || {
		error "Need '$1' (command not found)"
		exit 1
	}
}
#

# success/info/error/warn
msg() {
	printf '%b\n' "$1" >&2
}

success() {
	msg "${Green}[✔]${Color_off} ${1}${2}"
}

info() {
	msg "${Blue}[➭]${Color_off} ${1}${2}"
}

error() {
	msg "${Red}[✘]${Color_off} ${1}${2}"
	exit 1
}

warn() {
	msg "${Yellow}[⚠]${Color_off} ${1}${2}"
}
#

required_args=1

checkargs() {
	if [ "$#" -ne $required_args ]; then
		echo "Usage: $0 param1 param2"
		exit 1
	fi
}

### main
main() {
	checkargs "$@"
	echo "hello"
	warn "who"
	info "info"
	msg "msg"
	need_cmd lx
	success "success"
	error "boo"

} #

main "$@"

# vim:set nofoldenable foldmethod=marker:
