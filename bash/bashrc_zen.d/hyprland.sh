#
function hypdimon() {

  hyprctl keyword decoration:dim_strength 0.4
  hyprctl keyword decoration:dim_inactive true

}

function hypdimoff() {

  hyprctl keyword decoration:dim_inactive false

}

alias edithypr='nvim ~/gitdir/configs/pi/projs/hyprland/my-config/hyprland.lua'
alias edithyprl='nvim ~/.config/hypr/hyprland.lua'
