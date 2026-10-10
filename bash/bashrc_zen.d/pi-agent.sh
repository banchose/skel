alias cdpi='cd ~/gitdir/skel/pi'
alias cdpis='cd ~/gitdir/skel/pi/skills'
alias cdpid='cd ~/gitdir/configs/pi-dirs'
alias cdm='cd ~/temp/moon'
alias cdbills='cd ~/gitdir/configs/pi-dirs/bills'
alias editpi='nvim ~/gitdir/skel/bash/bashrc_zen.d/pi-agent.sh'

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
  rm "${llmpic}"
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "${llmpic}" | wl-copy

}

pt() {
  llmpic="$HOME/temp/pi-pic-one-shot.jpg"
  rm "${llmpic}"
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "${llmpic}" | wl-copy

}

pb() {

  rm ~/gitdir/configs/pi-dirs/bills/pics/*.jpg
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "$HOME/gitdir/configs/pi-dirs/bills/pics/pi-pic-one-shot.jpg" | wl-copy

}

px() {
  llmpic="$HOME/gitdir/configs/pi-dirs/xeyes/pics/pi-pic-one-shot.jpg"
  rm "${llmpic}"
  # grim -t jpeg -g "$(slurp -d)" - | tee "$HOME"/gitdir/configs/pi-dirs/bills/pics/pi-pic-"$(date "+%s").jpg" | wl-copy
  grim -t jpeg -g "$(slurp -d)" - | tee "${llmpic}" | wl-copy

}

# pi-backup: tar + xz + gpg (AES-256) ~/w -> ~/Dropbox/pi-w/pi-w-<epoch>.tar.xz.gpg
# Usage: pi-backup [-k N] [-n]
#   -k N  keep the newest N backups (default $PI_W_KEEP or 10; 0 = keep all)
#   -n    skip the check that decrypts and reads the new backup
pi-backup() (
  # The ( ) body runs in a subshell, so set -e, the trap and umask don't leak into your shell.
  # That's also why there's no `local`: these variables never reach your shell.
  # mkdir -p /tmp/w-restore
  #
  # gpg --batch --quiet --no-symkey-cache --pinentry-mode loopback --passphrase-fd 3 \
  #     -d ~/Dropbox/pi-w/pi-w-1760070000.tar.xz.gpg 3<<<"$PI_W_ENC_KEY" \
  #   | tar -xJf - -C /tmp/w-restore

  set -euo pipefail
  shopt -s nullglob
  umask 077

  src="$HOME/w"
  dest="$HOME/Dropbox/pi-w"
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
  if [[ ! $PI_W_ENC_KEY =~ ^sx-[0-9a-f]{64}$ ]]; then
    echo "pi-backup: warning: PI_W_ENC_KEY doesn't look like sx-<64 hex> (continuing)" >&2
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
  final="$dest/pi-w-${stamp}.tar.xz.gpg"
  if [[ -e $final ]]; then
    echo "pi-backup: $final already exists (two runs in the same second?)" >&2
    return 1
  fi

  mkdir -p -- "$dest" "$stage_root"

  # Register the cleanup trap before creating the temp folder
  cleanup() {
    if [[ -n $tmpdir ]]; then rm -rf -- "$tmpdir"; fi
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

  # Check the file decrypts and the tar inside is readable before it goes anywhere near Dropbox
  if ((verify)); then
    gpg --batch --quiet --no-symkey-cache --pinentry-mode loopback \
      --passphrase-fd 3 -d "$tmp" 3<<<"$PI_W_ENC_KEY" |
      xz -dc |
      tar -tf - >/dev/null
  fi

  # Same filesystem: instant rename. Different filesystem: copy, then delete
  mv -- "$tmp" "$final"
  printf 'pi-backup: wrote %s (%s)\n' "$final" "$(du -h -- "$final" | cut -f1)"

  # Delete old backups. Names sort oldest to newest because all epoch stamps are 10 digits
  if ((keep > 0)); then
    backups=("$dest"/pi-w-[0-9]*.tar.xz.gpg)
    n=${#backups[@]}
    if ((n > keep)); then
      rm -fv -- "${backups[@]:0:n-keep}"
    fi
  fi
)
