mm() {
  cd ~/y/youtube-down/ &&
    mpv "$(find . -maxdepth 1 -type f -printf "%T@ %p\n" |
      sort -nr |
      cut -d' ' -f2- |
      sed 's#\./##' |
      fzf --preview 'file {}; echo; stat {}')"
}
mma() (
  local dir=~/y/youtube-down/

  cd "$dir" || {
    echo "Failed to change to directory: $dir" >&2
    return
  }

  local file
  file=$(fzf) || {
    echo "No file selected." >&2
    return
  }

  # Ensure necessary tools are available
  command -v tmux >/dev/null || {
    echo "tmux is not installed." >&2
    return 1
  }
  command -v mpv >/dev/null || {
    echo "mpv is not installed." >&2
    return 1
  }

  # Use the filename for tmux window name
  tmux new-window -d -n "$(basename "$file")" "$(printf 'mpv ./%q' "$file")"
)

mmt() (
  local dir=~/y/youtube-down/

  cd "$dir" || {
    echo "Failed to change to directory: $dir" >&2
    return
  }

  local file
  file=$(fzf) || {
    echo "No file selected." >&2
    return
  }

  # Ensure necessary tools are available
  command -v tmux >/dev/null || {
    echo "tmux is not installed." >&2
    return 1
  }
  command -v mpv >/dev/null || {
    echo "mpv is not installed." >&2
    return 1
  }

  # Use the filename for tmux window name, abbreviating to the first 5 characters
  local filename
  filename=$(basename "$file") # Extract just the filename (no path components)
  local abbrev
  abbrev="${filename:0:5}" # Get the first 5 characters (safe even if shorter)

  # Create a new tmux window with the abbreviated name
  tmux new-window -d -n "$abbrev" "$(printf 'mpv ./%q' "$file")"
)
