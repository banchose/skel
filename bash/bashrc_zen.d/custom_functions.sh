# Some custom functions

get_oil() {
  readonly scriptfile=~/gitdir/skel/waybar/scripts/oil_price.sh
  [[ -r ${scriptfile} ]] || {
    echo "Can not read:  ${scriptfile}"
    return 1
  }
  "${scriptfile}"
}
