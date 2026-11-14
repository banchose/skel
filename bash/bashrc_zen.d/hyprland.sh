#

alias edithypr='nvim ~/gitdir/configs/pi/projs/hyprland/my-config/hyprland.lua'
alias edithyprl='nvim ~/.config/hypr/hyprland.lua'

dimon() {
  hyprctl eval 'hl.config({ decoration = { dim_inactive = true } })' # turn on dimming of inactive windows
}
dimoff() {
  hyprctl eval 'hl.config({ decoration = { dim_inactive = false } })' # turn it off
}

dimtoggle() {
  if [ "$(hyprctl -j getoption decoration.dim_inactive | jq -r .bool)" = true ]; then # read the current value
    hyprctl eval 'hl.config({ decoration = { dim_inactive = false } })'
  else
    hyprctl eval 'hl.config({ decoration = { dim_inactive = true } })'
  fi
}
