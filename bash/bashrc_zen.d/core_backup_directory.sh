bd() {
  (
    set -euo pipefail
    shopt -s nullglob
    umask 077

    usage() {
      printf 'Usage: bd DIR\n  Encrypted backup of DIR, written to the current directory.\n' >&2
    }

    if (($# != 1)); then
      usage
      exit 2
    fi

    missing=()
    for cmd in tar xz gpg realpath mktemp; do
      command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if ((${#missing[@]})); then
      printf 'bd: missing required commands: %s\n' "${missing[*]}" >&2
      exit 1
    fi

    if [[ -z ${PI_W_ENC_KEY:-} ]]; then
      echo 'bd: PI_W_ENC_KEY is not set' >&2
      exit 1
    fi
    if [[ ! $PI_W_ENC_KEY =~ ^sx-[0-9a-f]{64}$ ]]; then
      echo 'bd: PI_W_ENC_KEY must be sx-<64 hex> (make one with pi-get-key)' >&2
      exit 1
    fi

    # -d follows a symlink, so a link to a directory is accepted
    if [[ ! -d $1 ]]; then
      printf 'bd: %s is not a directory\n' "$1" >&2
      exit 1
    fi

    src=$(realpath -e -- "$1")
    home=$(realpath -e -- "$HOME")
    here=$(pwd -P)

    if [[ $src == / || $src == "$home" ]]; then
      printf 'bd: refusing to back up %s (no usable name)\n' "$src" >&2
      exit 1
    fi
    if [[ $here == "$src" || $here == "$src"/* ]]; then
      printf 'bd: current directory is inside %s; cd elsewhere first\n' "$src" >&2
      exit 1
    fi

    # Name: strip $HOME/ (or leading /), / -> -, odd chars -> _, leading . -> _
    if [[ $src == "$home"/* ]]; then
      rel=${src#"$home"/}
    else
      rel=${src#/}
    fi
    rel=${rel//\//-}
    rel=${rel//[^A-Za-z0-9._-]/_}
    if [[ $rel == .* ]]; then
      rel="_${rel:1}"
    fi
    if [[ -z $rel ]]; then
      printf 'bd: could not build a name from %s\n' "$src" >&2
      exit 1
    fi

    printf -v stamp '%(%Y%m%d-%H%M%S)T' -1
    printf -v rnd '%04d' "$((RANDOM % 10000))"
    final="$here/${rel}-${stamp}-${rnd}.tar.xz.gpg"

    if [[ -e $final || -L $final ]]; then
      printf 'bd: %s already exists\n' "$final" >&2
      exit 1
    fi

    tmp=""
    cleanup() {
      if [[ -n $tmp ]]; then
        command rm -f -- "$tmp"
      fi
      return 0
    }
    trap cleanup EXIT

    tmp=$(mktemp "$here/.bd.XXXXXX")

    parent=${src%/*}
    parent=${parent:-/}
    base=${src##*/}

    tar -C "$parent" -cf - -- "$base" |
      xz -T0 -6 |
      gpg --batch --yes --quiet --no-symkey-cache --pinentry-mode loopback \
        --passphrase-fd 3 --symmetric --cipher-algo AES256 --compress-algo none \
        -o "$tmp" 3<<<"$PI_W_ENC_KEY"

    contents=$(
      gpg --batch --quiet --no-symkey-cache --pinentry-mode loopback \
        --passphrase-fd 3 -d "$tmp" 3<<<"$PI_W_ENC_KEY" |
        xz -dc |
        tar -tf - |
        awk -F/ 'NF >= 2 && $2 != "" { print $2 }' |
        sort -u |
        paste -sd ' '
    )
    printf 'bd: contains: %s\n' "${contents:-(empty)}" >&2

    # Check again right before the rename
    if [[ -e $final || -L $final ]]; then
      printf 'bd: %s already exists\n' "$final" >&2
      exit 1
    fi
    command mv -- "$tmp" "$final"
    tmp=""

    printf 'bd: wrote %s (%s)\n' "$final" "$(command du -h -- "$final" | cut -f1)"
  )
}
