nvim_wipe() {

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

editnvimsh() {
  local nvim_sh_path="${HOME}/gitdir/skel/bash/bashrc_zen.d/nvim.sh"

  nvim "${nvim_sh_path}"
}

editnvimhelp() {
  local nvim_help_path="${HOME}/gitdir/skel/nvim/nvim-help.md"

  nvim "${nvim_help_path}"
}

nvim-help() {
  local nvim_help_path="${HOME}/gitdir/skel/nvim/nvim-help.md"
  local pager

  if command -v bat >/dev/null 2>&1; then
    pager=bat
  elif command -v less >/dev/null 2>&1; then
    pager=less
  elif command -v cat >/dev/null 2>&1; then
    pager=cat
  else
    printf >&2 'nvim-help: no usable pager found (bat/less/cat)\n'
    return 1
  fi

  if [[ ! -f "${nvim_help_path}" ]]; then
    printf >&2 'nvim-help: cannot find %s\n' "${nvim_help_path}"
    return 1
  fi

  "${pager}" "${nvim_help_path}"
}

get-astro() {

  local name=astronvim
  local configdir=~/.config/"${name}"
  local sharedir=~/.local/share/"${name}"

  [[ -d $configdir ]] && rm -rfv -- "$configdir"
  [[ -d $sharedir ]] && rm -rfv -- "$sharedir"

  git clone --depth 1 -- "https://github.com/${configdir##*/}/template" "$configdir" && rm -rf -- ~/"${configdir}/${name}".git

}

get-nvchad() {

  local name=nvchad
  local configdir=~/.config/"${name}"
  local sharedir=~/.local/share/"${name}"

  [[ -d $configdir ]] && rm -rfv -- "$configdir"
  [[ -d $sharedir ]] && rm -rfv -- "$sharedir"

  git clone --depth 1 -- "https://github.com/${configdir##*/}/${configdir##*/}" "$configdir" && rm -rf -- ~/"${configdir}/${name}".git
}

get-lazy() {

  local name=lazyvim
  local configdir=~/.config/"${name}"
  local sharedir=~/.local/share/"${name}"

  [[ -d $configdir ]] && rm -rfv -- "$configdir"
  [[ -d $sharedir ]] && rm -rfv -- "$sharedir"

  git clone --depth 1 -- "https://github.com/lazyvim/starter" "$configdir" && rm -rf -- ~/"${configdir}/${name}".git
}

get-space() {
  # Hard coded git
  local name=spacevim
  local configdir=~/.config/"${name}"
  local sharedir=~/.local/share/"${name}"

  [[ -d $configdir ]] && rm -rfv -- "$configdir"
  [[ -d $sharedir ]] && rm -rfv -- "$sharedir"

  git clone --depth 1 -- "https://gitlab.com/${configdir##*/}/${configdir##*/}" "${configdir,,}" && rm -rf -- ~/"${configdir}/${name}".git
}

get-default() {
  # Hard coded git
  local name=nvim
  local configdir=~/.config/"${name}"
  local sharedir=~/.local/share/"${name}"

  [[ -d $configdir ]] && rm -rfv -- "$configdir"
  [[ -d $sharedir ]] && rm -rfv -- "$sharedir"

  git clone --depth 1 -- "https://github.com/lazyvim/starter" "$configdir"
}

get-kickstart() {

  git clone --depth 1 "https://github.com/nvim-lua/kickstart.nvim" ~/.config/kickstart.nvim

}

astro() {

  if [[ -d $HOME/.config/astronvim ]]; then
    NVIM_APPNAME=astronvim nvim
  else
    echo "no astronvim in ~/.config"
  fi

}

nvims() {

  # This just gets a string from fzf and that sting must match
  # a directory in ~/.config
  # That directory should have the git repo of the nvim disto
  # So it may expect ~/.config/astronvim if you pick "astronvim" from the menu
  # Then set the handy NVIM_APPNAME=astronvim which must be name under ~/.config
  items=("default" "kickstart.nvim" "LazyVim" "NvChad" "AstroNvim" "SpaceVim")

  config=$(printf "%s\n" "${items[@]}" | fzf --prompt="Neovim Config >> " --height=50% --layout=reverse --border --exit-0)

  # Avoid case confusion caused by presentation
  # make sane
  items=("${items[@],,}")
  config="${config,,}"

  if [[ -z $config ]]; then
    echo "Nothing selected"
    retrun 0
  elif [[ $config == "default" ]]; then
    config=""
  fi

  NVIM_APPNAME="$config" nvim "$@"
}
