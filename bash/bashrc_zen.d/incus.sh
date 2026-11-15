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




   cat > mirror_woodlake.yaml <<'EOF'
   #cloud-config
   write_files:
     - path: /etc/pacman.d/mirrorlist
       owner: root:root
       permissions: '0644'
       content: |
         Server = http://star:9129/repo/archlinux/$repo/os/$arch
         Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
   EOF
   incus profile set arch-mirror cloud-init.vendor-data="$(cat mirror_woodlake.yaml)"


# A. cloud-init  write_files  in a profile (the "data block"; needs the
#  /cloud  image variant):
#
#   cat > mirror.yaml <<EOF
#   #cloud-config
#   write_files:
#     - path: /etc/pacman.d/mirrorlist
#       encoding: b64
#       content: $(base64 -w0 mirrorlist)
#       owner: root:root
#       permissions: '0644'
#   EOF
#
#   incus profile create arch-mirror                                # profile
# that holds the file
#   incus profile set arch-mirror cloud-init.vendor-data="$(cat mirror.yaml)"
# # vendor-data: leaves user-data free
#   incus launch images:archlinux/cloud v1 --vm -p default -p archvm -p arch-
# mirror   # written on first boot
#   incus exec v1 -- cloud-init status --wait                       # wait
# until cloud-init is done
#   incus exec v1 -- head /etc/pacman.d/mirrorlist                  # check
#
#  base64 -w0  makes the file one line, so its content needs no YAML
# indenting. To write it in plain text instead, use
#  content: |  and indent every line of the file under it.
#
# B. Push it after launch (works with the plain image, no cloud-init):
#
#   incus launch images:archlinux v2 --vm -p default -p archvm      # plain
# image
#   until incus exec v2 -- true 2>/dev/null; do sleep 1; done       # wait for
# incus-agent
#   incus file push mirrorlist v2/etc/pacman.d/mirrorlist --uid 0 --gid 0 --
# mode 0644   # overwrite the image's copy
#
# C. Bake it into an image: push the file into a build VM and  incus
# publish  it; every VM launched from that image has it. Steps in
# create-image-with-setup.md
# /home/una/gitdir/configs/pi/projs/incus/howtos/create-image-with-setup.md
# (B).
