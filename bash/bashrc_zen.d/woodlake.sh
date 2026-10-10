# export heliospass

user=api
# user=admin

function getjwt() {
  curl -X POST -s -k -u "${user}:${heliospass}" https://helios.example.net/api/v2/auth/jwt
}
# getjwt  | jq -r '.data.token'

function wood-sync() {
  local SyncDest=star
  ping -q -w 2 -l 2 -c 1 "${SyncDest}" &>/dev/null || {
    echo "${SyncDest} not responding"
    return 1
  }
  rsync -rvptgle ssh /home/una/y/youtube-down star.xaax.dev:/sync/"${HOSTNAME}"
  rsync --del -rvptgle ssh /home/una/gitdir star.xaax.dev:/sync/"${HOSTNAME}"
  rsync -rvptgle ssh /home/una/temp/OPENBKDIR* star.xaax.dev:/sync/"${HOSTNAME}"
  rsync --del -rvptgle ssh /home/una/Dropbox star.xaax.dev:/sync/"${HOSTNAME}"
  rsync --del -rvptgle ssh /home/una/.config/ star.xaax.dev:/sync/"${HOSTNAME}"/dotconfig
  rsync --del -rvptgle ssh /home/una/Downloads star.xaax.dev:/sync/"${HOSTNAME}"

}

testapps() {
  local services=(privatebin whoami librechat dashy dozzle)
  for service in "${services[@]}"; do
    curl -I -L https://"${service}".xaax.dev
  done
}

dimon() {

  # Hyprland hyprland sway

  hyprctl keyword decoration:dim_inactive true

}

dimoff() {

  # Hyprland hyprland sway

  hyprctl keyword decoration:dim_inactive false

}

wood_help() {

  cat <<'EOF'
Wifi: 192.168.200.100 Name:	atlas.xaax.dev
Wifi in access mode so ethernet/wifi on same network .200.0/24 at .1
Wifi has no services (access mode and NO dns and NO dhcp
Wifi gets dhcp from the firewall
Wifi gets DNS from ns2
Wifi in access mode so ethernet/wifi on same network .200.0/24
Wifi network allows dns to .2: 192.168.2.2/24
Firewall: Netgate 6100: 192.168.2.1, 192.168.10.1/24, 192.168.1.150/24, 192.168.200.1/24
  INTWAN1IX3 (wan)      -> ix3  -> v4: 192.168.1.150/24
  ARCLAN1IGC0 (lan)     -> igc0 -> v4: 192.168.10.1/24
  IX2 (opt1)            -> ix2  ->
  OFFIX0WAN3 (opt2)     -> ix0  -> v4: 192.168.6.1/24
  GWAN4SWITCHIX1 (opt3) -> ix1  -> v4: 192.168.2.1/24
  WIFINET (opt4)        -> igc1 -> v4: 192.168.200.1/24
  OFFIGC2LAN3 (opt5)    -> igc2 ->
  OFFIGC3LAN4 (opt6)    -> igc3 ->
arc on .10.0/24 network at .10
ns2: 192.168.2.2/24
ns2: DNS by pi-hole (no container)
EOF
}
