bat_show_themes() {
  bat --list-themes | while IFS= read -r theme; do
    echo "${theme}"
    bat -r 10:15 --theme "${theme}" ~/gitdir/skel/nvim/nvim-help.md
  done
}
