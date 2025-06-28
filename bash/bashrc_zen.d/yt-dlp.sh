# sourcing

UserAgent='Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1'

TestLink='https://www.youtube.com/watch?v=_7dfFtAPVHE'

VidDir=~/y/youtube-down/
mm() {
  cd ~/y/youtube-down/ || return

  local file
  file=$(find . -maxdepth 1 -type f -printf "%T@ %p\n" |
    sort -nr |
    cut -d' ' -f2- |
    sed 's#\./##' |
    fzf --preview 'file {}; echo; stat {}')

  # Only run mpv if a file was selected
  if [[ -n "$file" ]]; then
    mpv --no-audio-display "$file"
  else
    echo "No file selected."
  fi
}

mmv() {
  cd ~/y/youtube-down/ || return

  local file
  file=$(find . -maxdepth 1 -type f -printf "%T@ %p\n" |
    sort -nr |
    cut -d' ' -f2- |
    sed 's#\./##' |
    fzf --preview 'file {}; echo; stat {}')

  # Only run mpv if a file was selected
  if [[ -n "$file" ]]; then
    mpv "$file"
  else
    echo "No file selected."
  fi
}

yta() {
  # get best audio any format
  (
    cd "$VidDir" || {
      echo "missing $VidDir"
      return 1
    }
    yt-dlp --user-agent "$UserAgent" --ignore-errors --format bestaudio --extract-audio --output "%(title)s.%(ext)s" "$1"
  )
}

ytam() {
  (
    # get best mp3 audio
    cd "$VidDir" || {
      echo "missing $VidDir"
      return 1
    }
    yt-dlp --user-agent "$UserAgent" --ignore-errors --format bestaudio --extract-audio --audio-format mp3 --output "%(title)s.%(ext)s" "$1"
  )
}

ytv() {
  (
    cd "$VidDir" || {
      echo "missing $VidDir"
      return 1
    }
    yt-dlp --live-from-start --max-downloads 5 --no-playlist --user-agent 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1' --format 'bestvideo+bestaudio/best' "$1"
  )
}

tytv() {
  (
    cd "$VidDir" || {
      echo "missing $VidDir"
      return 1
    }
    tmux new-session -d -s "ytv" \
      yt-dlp \
      --live-from-start \
      --max-downloads 5 \
      --no-playlist \
      --user-agent 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1' --format 'bestvideo+bestaudio/best' \
      "${1}"
    if [[ $? -ne 0 ]]; then
      echo "Do you need to single quote the URL string?"
    fi
  )
}

ytv-pl() {
  (
    cd "$VidDir" || {
      echo "missing $VidDir"
      return 1
    }
    yt-dlp --yes-playlist --live-from-start --max-downloads 5 --user-agent 'Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Mobile/15E148 Safari/604.1' --format 'bestvideo+bestaudio/best' "$1"
  )
}
