#!/usr/bin/env bash

WIPE_NVIM() {

  # required
  [[ -d ~/.config/nvim ]] || {
    echo "~/.config/nvim already gone"
    return 0
  }
  mv -v -- ~/.config/nvim{,.bak}

  # optional but recommended
  mv -v -- ~/.local/share/nvim{,.bak}
  mv -v -- ~/.local/state/nvim{,.bak}
  mv -v -- ~/.cache/nvim{,.bak}
}

safe_input() {
  local prompt="$1"
  local regex="$2"
  local input

  while true; do
    read -r -p "$prompt" input
    # Check against the regex if provided
    if [[ -n "$regex" && ! "$input" =~ $regex ]]; then
      echo "Invalid input. Please try again."
    else
      # Escape special characters to prevent injection
      input=$(printf '%q' "$input")
      echo "$input"
      return
    fi
  done
}
NVIM_INSTALL() {
  echo "#####################"
  echo "Ubuntu"
  echo "insturctions on installing nvim"
  echo "xudo add-apt-repository ppa:neovim-ppa/unstable -y"
  echo "xudo apt update"
  echo "xudo apt install make gcc ripgrep unzip git xclip neovim"
  echo "#####################"
  echo "Install Arch Linux"
  echo "xudo pacman -S --noconfirm --needed gcc make git fzf tmux jq ripgrep fd unzip neovim"

}
