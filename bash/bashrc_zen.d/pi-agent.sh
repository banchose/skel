# This file is hardlinked into configs/pi-dirs/mypi so the model can edit it from the container.
# -ef is true when both paths are the same inode. If git ever replaces one side, this says so.
if [[ ! ~/gitdir/skel/bash/bashrc_zen.d/pi-agent.sh -ef ~/gitdir/configs/pi-dirs/mypi/scripts/pi-agent.sh ]]; then
  echo "pi-agent.sh: hardlink to mypi/scripts/pi-agent.sh is broken; diff both, then fix with:" >&2
  echo "  ln -f ~/gitdir/skel/bash/bashrc_zen.d/pi-agent.sh ~/gitdir/configs/pi-dirs/mypi/scripts/pi-agent.sh" >&2
fi

alias cdpi='cd ~/gitdir/skel/pi'
alias cdpis='cd ~/gitdir/skel/pi/skills'
alias cdpid='cd ~/gitdir/configs/pi-dirs'
alias cdoil='cd ~/gitdir/configs/pi-dirs/oil'
alias cdm='cd ~/moon'
alias cdbills='cd ~/gitdir/configs/pi-dirs/bills'
alias editpi='nvim ~/gitdir/skel/bash/bashrc_zen.d/pi-agent.sh'

# Start Pi
pi() { pi-bed "$@"; }
pish() { pi-bed -b "$@"; }
piroot() { pi-bed -u "$@"; }

moon() {

  local PIDIR=~/moon
  cd "${PIDIR}" || {
    echo "no ${PIDIR}"
    return 1
  }
  pi-bed
}

pim() {
  moon
}

pi-bed() {
  if ! docker info >/dev/null 2>&1; then
    echo "docker daemon is not running" 1>&2
    return 1
  fi
  local entrypoint_args=()
  if [[ "${1:-}" == "-b" ]]; then
    entrypoint_args=(--entrypoint bash)
    shift
  elif [[ "${1:-}" == "-u" ]]; then
    entrypoint_args=(-u 0 --entrypoint bash)
    shift
  fi
  printf '%s\n' "$(pwd)"
  docker run --rm -it "${entrypoint_args[@]}" \
    -e WOLFRAM_APP_ID \
    -e FASTMAIL_API_TOKEN \
    -e TOMTOM_API_KEY \
    -e TINFOIL_API_KEY \
    -e OPENROUTER_API_KEY \
    -e EDITOR="nvim" \
    -e ENGRAM_HOME="/home/node/.engram" \
    -e ANTHROPIC_API_KEY \
    -e AWS_BEARER_TOKEN_BEDROCK \
    -e EXA_API_KEY \
    -e LAT \
    -e LON \
    -e OPENWEATHER_APP_ID \
    -e PONYTAIL_DEFAULT_MODE=off \
    -e SHELL=/bin/bash \
    -e TERM \
    -v "$PWD:/workspace" \
    -v pi-agent-home:/home/node/.pi/agent \
    pi-sandbox "$@"
}

alias pi-pic='grim -t jpeg -g "$(slurp -d)" - | tee ./pi-pic-"$(date "+%s").jpg" | wl-copy'
alias pp='grim -t jpeg -g "$(slurp -d)" - | tee ./pi-pic-"$(date "+%s").jpg" | wl-copy'

pi-get-key() {

  echo "sx-$(openssl rand -hex 32)"
}

pm() {
  llmpic="$HOME/temp/moon/pi-pic-one-shot.jpg"
  rm -f "${llmpic}"
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "${llmpic}" | wl-copy

}

pt() {
  llmpic="$HOME/temp/pi-pic-one-shot.jpg"
  rm -f "${llmpic}"
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "${llmpic}" | wl-copy

}

pb() {

  rm -f ~/gitdir/configs/pi-dirs/bills/pics/*.jpg
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "$HOME/gitdir/configs/pi-dirs/bills/pics/pi-pic-one-shot.jpg" | wl-copy

}

px() {
  llmpic="$HOME/gitdir/configs/pi-dirs/xeyes/pics/pi-pic-one-shot.jpg"
  rm -f "${llmpic}"
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "${llmpic}" | wl-copy

}

# pi-backup: tar + xz + gpg (AES-256) ~/piland -> ~/Dropbox/pi-backup/pi-backup-<epoch>.tar.xz.gpg
# Every directory under ~/piland is a git repo with no remote, so this archive is
# the only off-disk copy of those repos, their history, and their untracked files.
# Usage: pi-backup [-k N] [-n]
#   -k N  keep the newest N backups (default $PI_W_KEEP or 10; 0 = keep all)
#   -n    skip the check that decrypts and reads the new backup
pi-backup() (
  # The ( ) body runs in a subshell, so set -e, the trap and umask don't leak into your shell.
  # That's also why there's no `local`: these variables never reach your shell.
  #
  # Restore (creates /tmp/pi-restore/piland/<repo>/...):
  #   mkdir -p /tmp/pi-restore
  #   gpg --batch --quiet --no-symkey-cache --pinentry-mode loopback --passphrase-fd 3 \
  #       -d ~/Dropbox/pi-backup/pi-backup-1760070000.tar.xz.gpg 3<<<"$PI_W_ENC_KEY" \
  #     | tar -xJf - -C /tmp/pi-restore

  set -euo pipefail
  shopt -s nullglob
  umask 077

  src="$HOME/piland"
  dest="$HOME/Dropbox/pi-backup"
  stage_root="${XDG_CACHE_HOME:-$HOME/.cache}" # outside Dropbox, usually the same filesystem
  keep="${PI_W_KEEP:-10}"
  verify=1
  tmpdir=""
  OPTIND=1

  usage() {
    printf 'Usage: pi-backup [-k N] [-n]\n  -k N  keep newest N backups (0 = keep all)\n  -n    skip the post-backup check\n' >&2
  }

  while getopts ':k:nh' opt; do
    case $opt in
    k) keep=$OPTARG ;;
    n) verify=0 ;;
    h)
      usage
      return 0
      ;;
    *)
      usage
      return 2
      ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ ! $keep =~ ^[0-9]+$ ]]; then
    echo "pi-backup: -k must be a non-negative integer" >&2
    return 2
  fi
  keep=$((10#$keep)) # force base 10: a leading 0 would otherwise mean octal and break on 08/09

  # Dependency check: report everything that's missing at once
  missing=()
  for cmd in tar xz gpg; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if ((${#missing[@]})); then
    printf >&2 'pi-backup: missing required commands: %s\n' "${missing[*]}"
    return 1
  fi

  # Key checks
  if [[ -z ${PI_W_ENC_KEY:-} ]]; then
    echo "pi-backup: PI_W_ENC_KEY is not set" >&2
    return 1
  fi
  # Hard error: the security of a file left on a public endpoint rests entirely on this key being random
  if [[ ! $PI_W_ENC_KEY =~ ^sx-[0-9a-f]{64}$ ]]; then
    echo "pi-backup: PI_W_ENC_KEY must be sx-<64 hex> (make one with pi-get-key)" >&2
    return 1
  fi

  # Source checks
  if [[ -L $src ]]; then
    echo "pi-backup: $src is a symlink; tar would save only the link, not its contents" >&2
    return 1
  fi
  if [[ ! -d $src ]]; then
    echo "pi-backup: source $src not found" >&2
    return 1
  fi

  stamp="$EPOCHSECONDS"
  final="$dest/pi-backup-${stamp}.tar.xz.gpg"
  if [[ -e $final ]]; then
    echo "pi-backup: $final already exists (two runs in the same second?)" >&2
    return 1
  fi

  mkdir -p -- "$dest" "$stage_root"

  # Register the cleanup trap before creating the temp folder
  cleanup() {
    if [[ -n $tmpdir ]]; then command rm -rf -- "$tmpdir"; fi
    return 0
  }
  trap cleanup EXIT

  tmpdir=$(mktemp -d "$stage_root/pi-backup.XXXXXX")
  tmp="$tmpdir/${final##*/}"

  # Passphrase goes in on fd 3 (here-string), so it never appears in argv or ps
  # --compress-algo none: the data is already xz-compressed
  tar -C "${src%/*}" -cf - "${src##*/}" |
    xz -T0 -6 |
    gpg --batch --yes --quiet --no-symkey-cache --pinentry-mode loopback \
      --passphrase-fd 3 --symmetric --cipher-algo AES256 \
      --compress-algo none -o "$tmp" 3<<<"$PI_W_ENC_KEY"

  # Check the file decrypts and the tar inside is readable before it goes anywhere near Dropbox,
  # and print the top-level entries (the repos) so you can see they all made it
  if ((verify)); then
    gpg --batch --quiet --no-symkey-cache --pinentry-mode loopback \
      --passphrase-fd 3 -d "$tmp" 3<<<"$PI_W_ENC_KEY" |
      xz -dc |
      tar -tf - |
      awk -F/ 'NF >= 2 && $2 != "" { print $2 }' | sort -u | paste -sd ' ' |
      sed 's/^/pi-backup: contains: /' >&2
  fi

  # Same filesystem: instant rename. Different filesystem: copy, then delete
  # `command` skips shell aliases (mv -v, du -c, ...) that would otherwise be baked into this function
  command mv -- "$tmp" "$final"
  printf 'pi-backup: wrote %s (%s)\n' "$final" "$(command du -h -- "$final" | cut -f1)"

  # Delete old backups. Names sort oldest to newest because all epoch stamps are 10 digits
  if ((keep > 0)); then
    backups=("$dest"/pi-backup-[0-9]*.tar.xz.gpg)
    n=${#backups[@]}
    if ((n > keep)); then
      command rm -fv -- "${backups[@]:0:n-keep}"
    fi
  fi
)

piland-backup() {

  rsync -avu --exclude='/.git/' /home/una/piland/proj-tmpl/ ~/gitdir/configs/pi-dirs/proj-tmpl/
  rsync -avu --exclude='/.git/' /home/una/piland/ufo/ ~/gitdir/configs/pi-dirs/ufo/
}
