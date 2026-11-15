# Bail early if the command isn't available (only meaningful when sourced)
(return 0 2>/dev/null) || {
  printf >&2 '%s: must be sourced, not executed\n' "${BASH_SOURCE[0]}"
  exit 1
}
command -v incus >/dev/null 2>&1 || return 0

alias lxc='echo "Use incus"'

alias editincus='nvim ~/gitdir/skel/bash/bashrc_zen.d/incus.sh'

# shellcheck shell=bash
# incus_launch_arch: launch an Arch Linux VM with a local pacman mirrorlist.
#
# Purpose:    Launch an Arch VM from images:archlinux/cloud with profile
#             arch-cloud (4GiB, Secure Boot off, and cloud-init vendor-data:
#             pacman mirrorlist, a sudoers drop-in letting group wheel
#             sudo with a password, user una in wheel with bash and no
#             password, a full upgrade and the packages below).
#             Create or refresh the profile first, and return once
#             cloud-init has finished.
# Usage:      incus_launch_arch [vm-name]   (bash function, sourced; default
#             name vm-YYYYMMDD-HHMMSS)
# Output:     incus's launch output on stdout; progress and errors on
#             stderr, prefixed "incus_launch_arch:".
# Exit codes: 0 VM up and cloud-init done (a warning if cloud-init reports
#             recoverable errors); 1 error (no incus, name taken,
#             profile/launch failed, timeout, cloud-init error); 2 usage.
# Steps:      1. checks: incus in PATH, args, duplicate name
#             2. create the profile if missing; on every run, set
#                limits.memory, security.secureboot, cloud-init.vendor-data
#             3. incus launch images:archlinux/cloud NAME --vm -p default -p arch-cloud
#             4. wait (10 min in total): poll every 3s until the VM's
#                /etc/pacman.d/mirrorlist matches the one below (this gets
#                past the incus-agent's first-boot reboot), then run
#                `cloud-init status --wait`
# Edge cases: name taken -> exit 1 before touching the profile.
#             Profile hand-edited -> only those 3 keys are overwritten.
#             Timeout or cloud-init error -> VM left running, message says so.
#             Mirror host unreachable -> not checked; pacman falls back to
#             the next Server line.
#             Package install fails -> cloud-init reports it; exit 1 or a
#             warning, as for any cloud-init error.
#             The user gets no password: set one with `passwd` before
#             using sudo (the function prints the command).
# Non-goals:  never deletes a VM; doesn't touch other profiles; no flags
#             besides the name; no `set -e` (it's sourced into the shell).
# Example:    incus_launch_arch dev1 -> dev1 runs, mirrorlist has the 2 Server lines,
#             user una exists (no password yet), the packages are installed
#             incus_launch_arch dev1 again -> "already exists", exit 1
#             incus_launch_arch a b -> usage, exit 2
#
# Changing limits.memory below also resizes running VMs that use the
# profile, on the next run (the key is live-updatable). The Secure Boot
# setting applies at their next boot. vendor-data only affects new VMs.

incus_launch_arch() {
  local profile=arch-cloud
  local image=images:archlinux/cloud
  local memory=4GiB
  local timeout=600 # seconds, for the whole cloud-init wait (upgrade + packages)

  # Installed on first boot, after a full upgrade (pacman -Syu).
  local packages=(git tmux sudo jq bash-completion curl)
  local user=una # created in group wheel, shell bash, password locked

  # The mirrorlist written into every new VM. Quoted heredoc, so pacman's
  # $repo and $arch stay literal. Lines must start at column 0.
  local mirrorlist
  mirrorlist=$(
    cat <<'EOF'
Server = http://star:9129/repo/archlinux/$repo/os/$arch
Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
EOF
  )

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

  # cloud-config: the mirrorlist as base64, so it needs no YAML indenting;
  # a sudoers drop-in instead of editing /etc/sudoers (a pacman backup
  # file); package_upgrade so the install isn't a partial upgrade.
  local b64
  if ! b64=$(printf '%s\n' "$mirrorlist" | base64 -w0); then
    printf 'incus_launch_arch: base64 failed\n' >&2
    return 1
  fi
  local vendor_data
  printf -v vendor_data '%s\n' \
    '#cloud-config' \
    'write_files:' \
    '  - path: /etc/pacman.d/mirrorlist' \
    '    encoding: b64' \
    "    content: $b64" \
    '    owner: root:root' \
    "    permissions: '0644'" \
    '  - path: /etc/sudoers.d/10-wheel' \
    '    content: "%wheel ALL=(ALL:ALL) ALL\n"' \
    '    owner: root:root' \
    "    permissions: '0440'" \
    'users:' \
    "  - name: $user" \
    '    groups: wheel' \
    '    shell: /bin/bash' \
    '    lock_passwd: true' \
    'package_upgrade: true' \
    'packages:'
  local pkg
  for pkg in "${packages[@]}"; do
    vendor_data+="  - $pkg"$'\n'
  done

  if ! incus profile show "$profile" >/dev/null 2>&1; then
    if ! incus profile create "$profile"; then
      printf 'incus_launch_arch: could not create profile %q\n' "$profile" >&2
      return 1
    fi
  fi
  if ! incus profile set "$profile" \
    limits.memory="$memory" \
    security.secureboot=false \
    cloud-init.vendor-data="$vendor_data"; then
    printf 'incus_launch_arch: could not set profile %q\n' "$profile" >&2
    return 1
  fi

  if ! incus launch "$image" "$name" --vm -p default -p "$profile"; then
    printf 'incus_launch_arch: launch of %q failed\n' "$name" >&2
    return 1
  fi

  printf 'incus_launch_arch: waiting for cloud-init in %s (up to %ss)\n' \
    "$name" "$timeout" >&2
  local deadline=$((SECONDS + timeout))
  local got
  until got=$(incus file pull "$name/etc/pacman.d/mirrorlist" - 2>/dev/null) &&
    [[ $got == "$mirrorlist" ]]; do
    if ((SECONDS >= deadline)); then
      printf 'incus_launch_arch: timed out; %s is still running. Check with:\n' \
        "$name" >&2
      printf '  incus exec %q -- cloud-init status --long\n' "$name" >&2
      return 1
    fi
    sleep 3
  done

  local left=$((deadline - SECONDS))
  if ((left < 5)); then
    left=5
  fi
  local rc=0
  timeout "$left" incus exec "$name" -- cloud-init status --wait >/dev/null ||
    rc=$?
  case $rc in
  0)
    printf 'incus_launch_arch: %s is ready. Set a password for %s with:\n' \
      "$name" "$user" >&2
    printf '  incus exec %q -- passwd %q\n' "$name" "$user" >&2
    ;;
  2)
    printf 'incus_launch_arch: %s is up, but cloud-init reported recoverable errors:\n' \
      "$name" >&2
    printf '  incus exec %q -- cloud-init status --long\n' "$name" >&2
    ;;
  124)
    printf 'incus_launch_arch: timed out waiting for cloud-init; %s is still running\n' \
      "$name" >&2
    return 1
    ;;
  *)
    printf 'incus_launch_arch: cloud-init failed in %s (exit %d). Check with:\n' \
      "$name" "$rc" >&2
    printf '  incus exec %q -- cloud-init status --long\n' "$name" >&2
    return 1
    ;;
  esac
}

vmpaste() { wl-paste | incus file push - "$1/home/una/clip.txt" --uid 1000 --gid 1000; } # host clipboard -> VM file
vmcopy() { incus file pull "$1/home/una/${2:-clip.txt}" - | wl-copy; }                   # VM file -> host clipboard

# incus launch images:archlinux archvm --vm -c limits.memory=16GiB -c security.secureboot=false -c limits.cpu=4
#
#  incus profile create archvm
#  incus profile set archvm limits.memory=4GiB security.secureboot=false
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
# incus_launch_arch() {
#   local profile=arch-cloud
#   local image=images:archlinux/cloud
#   local memory=4GiB
#   local timeout=120 # seconds, for the whole cloud-init wait
#
#   # The mirrorlist written into every new VM. Quoted heredoc, so pacman's
#   # $repo and $arch stay literal. Lines must start at column 0.
#   local mirrorlist
#   mirrorlist=$(
#     cat <<'EOF'
# Server = http://star.xaax.dev:9129/repo/archlinux/$repo/os/$arch
# Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
# EOF
#   )
#
#   if ! command -v incus >/dev/null 2>&1; then
#     printf 'incus_launch_arch: incus command not found in PATH\n' >&2
#     return 1
#   fi
#
#   if (($# > 1)); then
#     printf 'usage: incus_launch_arch [vm-name]\n' >&2
#     return 2
#   fi
#
#   local name=${1:-}
#   if [[ -z $name ]]; then
#     name="vm-$(date +%Y%m%d-%H%M%S)"
#   fi
#
#   local existing
#   if ! existing=$(incus list --format csv -c n); then
#     printf 'incus_launch_arch: could not list existing instances\n' >&2
#     return 1
#   fi
#
#   local line
#   while IFS= read -r line; do
#     if [[ $line == "$name" ]]; then
#       printf 'incus_launch_arch: an instance named %q already exists\n' \
#         "$name" >&2
#       return 1
#     fi
#   done <<<"$existing"
#
#   # cloud-config with the mirrorlist as base64, so it needs no YAML indenting.
#   local b64
#   if ! b64=$(printf '%s\n' "$mirrorlist" | base64 -w0); then
#     printf 'incus_launch_arch: base64 failed\n' >&2
#     return 1
#   fi
#   local vendor_data
#   printf -v vendor_data '%s\n' \
#     '#cloud-config' \
#     'write_files:' \
#     '  - path: /etc/pacman.d/mirrorlist' \
#     '    encoding: b64' \
#     "    content: $b64" \
#     '    owner: root:root' \
#     "    permissions: '0644'"
#
#   if ! incus profile show "$profile" >/dev/null 2>&1; then
#     if ! incus profile create "$profile"; then
#       printf 'incus_launch_arch: could not create profile %q\n' "$profile" >&2
#       return 1
#     fi
#   fi
#   if ! incus profile set "$profile" \
#     limits.memory="$memory" \
#     security.secureboot=false \
#     cloud-init.vendor-data="$vendor_data"; then
#     printf 'incus_launch_arch: could not set profile %q\n' "$profile" >&2
#     return 1
#   fi
#
#   if ! incus launch "$image" "$name" --vm -p default -p "$profile"; then
#     printf 'incus_launch_arch: launch of %q failed\n' "$name" >&2
#     return 1
#   fi
#
#   printf 'incus_launch_arch: waiting for cloud-init in %s (up to %ss)\n' \
#     "$name" "$timeout" >&2
#   local deadline=$((SECONDS + timeout))
#   local got
#   until got=$(incus file pull "$name/etc/pacman.d/mirrorlist" - 2>/dev/null) &&
#     [[ $got == "$mirrorlist" ]]; do
#     if ((SECONDS >= deadline)); then
#       printf 'incus_launch_arch: timed out; %s is still running. Check with:\n' \
#         "$name" >&2
#       printf '  incus exec %q -- cloud-init status --long\n' "$name" >&2
#       return 1
#     fi
#     sleep 3
#   done
#
#   local left=$((deadline - SECONDS))
#   if ((left < 5)); then
#     left=5
#   fi
#   local rc=0
#   timeout "$left" incus exec "$name" -- cloud-init status --wait >/dev/null ||
#     rc=$?
#   case $rc in
#   0)
#     printf 'incus_launch_arch: %s is ready\n' "$name" >&2
#     ;;
#   2)
#     printf 'incus_launch_arch: %s is up, but cloud-init reported recoverable errors:\n' \
#       "$name" >&2
#     printf '  incus exec %q -- cloud-init status --long\n' "$name" >&2
#     ;;
#   124)
#     printf 'incus_launch_arch: timed out waiting for cloud-init; %s is still running\n' \
#       "$name" >&2
#     return 1
#     ;;
#   *)
#     printf 'incus_launch_arch: cloud-init failed in %s (exit %d). Check with:\n' \
#       "$name" "$rc" >&2
#     printf '  incus exec %q -- cloud-init status --long\n' "$name" >&2
#     return 1
#     ;;
#   esac
# }

# cat > mirror_woodlake.yaml <<'EOF'
# #cloud-config
# write_files:
#   - path: /etc/pacman.d/mirrorlist
#     owner: root:root
#     permissions: '0644'
#     content: |
#       Server = http://star:9129/repo/archlinux/$repo/os/$arch
#       Server = https://mirrors.rit.edu/archlinux/$repo/os/$arch
# EOF
# incus profile set arch-mirror cloud-init.vendor-data="$(cat mirror_woodlake.yaml)"

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
#

# Setting up gpu for wayland
## On the Host
# sudo pacman -S --needed qemu-ui-egl-headless qemu-hw-display-virtio-vga-gl qemu-hw-display-virtio-gpu-gl
# qemu-hw-display-virtio-gpu-pci qemu-hw-display-virtio-gpu-pci-gl   # also pulls in virglrenderer
# incus stop archvm                                               # this device can't be added to a running VM
# incus config device add archvm gpu0 gpu gputype=native-context  # add the GPU device
# incus start archvm --console=vga
#
# incus console --type vga vm-1234
#

## In VM (vm-1234)
# pacman -S mesa-utils vulkan-tools vulkan-radeon   # use vulkan-intel on Intel
# eglinfo -B

## Copy/Paste spice/wayland/clipboard
# wl-paste | incus file push - vm1/home/una/clip.txt --uid 1000 --gid 1000   # host clipboard into a file una owns
# incus file pull vm1/home/una/out.txt - | wl-copy
