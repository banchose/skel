# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v incus >/dev/null 2>&1 || return 0

alias lxc='echo "Use incus"'

alias editincus='nvim ~/gitdir/skel/bash/bashrc_zen.d/incus.sh'

# incus launch images:archlinux archvm --vm -c limits.memory=16GiB -c security.secureboot=false -c limits.cpu=4
#
#  incus profile create archvm                                                                                                         │
#  incus profile set archvm limits.memory=4GiB security.secureboot=false                                                              │
#  incus launch images:archlinux archvm2 --vm -p default -p archvm
#  incus shell archvm2
#

## Default only
# incus launch images:archlinux my_v3 --vm -c security.secureboot=false
## Default + archvm
# incus launch images:archlinux my_v3 --vm -p default -p archvm
## One off
# incus launch images:archlinux my_v3 --vm -p default -p archvm -c limits.memory=4GiB
#
incus_launch_arch() {
  if ! command -v incus >/dev/null 2>&1; then
    printf 'incus_launch_arch: incus command not found in PATH\n' >&2
    return 1
  fi

  if (($# > 1)); then
    printf 'usage: incus_launch_arch [vm-name]\n' >&2
    return 2
  fi

  local name=${1:-}
  if [[ -z $name ]]; then
    name="vm-$(date +%Y%m%d-%H%M%S)"
  fi

  local existing
  if ! existing=$(incus list --format csv -c n); then
    printf 'incus_launch_arch: could not list existing instances\n' >&2
    return 1
  fi

  local line
  while IFS= read -r line; do
    if [[ $line == "$name" ]]; then
      printf 'incus_launch_arch: an instance named %q already exists\n' \
        "$name" >&2
      return 1
    fi
  done <<<"$existing"

  incus launch images:archlinux "$name" --vm \
    -c limits.memory=4GiB \
    -c security.secureboot=false
}
