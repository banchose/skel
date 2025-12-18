lsbtrfs() {
	for item in */; do
		if btrfs subvolume show "$item" &>/dev/null; then
			echo "[SUBVOL] $item"
		else
			echo "[DIR]    $item"
		fi
	done
}
