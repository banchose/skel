#!/usr/bin/env bash
#
#
function hypdimon() {

  hyprctl keyword decoration:dim_strength 0.4
  hyprctl keyword decoration:dim_inactive true

}

function hypdimoff() {

  hyprctl keyword decoration:dim_inactive false

}
