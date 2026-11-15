# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v ssh >/dev/null 2>&1 || return 0
# load ssh key
loadkey() {
  pidof ssh-agent
  pkill ssh-agent
  eval "$(ssh-agent)" && ssh-add
}

sky() {
  # see if loaded or load ssh key
  command ssh-add -l | command grep id_rsa && {
    echo "A key is already loaded."
    return 1
  }
  command pkill ssh-agent
  eval "$(ssh-agent)" && command ssh-add
}

# set in ~/.config/environment.d/ssh-agent.conf
# export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gcr/ssh"

# loadAgent() {
# 	set -x
# 	if ! pgrep -u "$USER" ssh-agent >/dev/null; then
# 		ssh-agent -t 1h >|"$XDG_RUNTIME_DIR/ssh-agent.env"
# 	fi
# 	echo "here is sock: $SSH_AUTH_SOCK"
#
# 	if [[ ! -n $SSH_AUTH_SOCK ]]; then
# 		echo "here is sock: $SSH_AUTH_SOCK"
# 		source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
# 		ssh-add
# 		echo "who"
# 	fi
# 	set +x
# }
