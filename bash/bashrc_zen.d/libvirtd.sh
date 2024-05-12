# clusterVMs=(
# 	"192.168.122.120"
# 	"192.168.122.121"
# 	"192.168.122.122"
# 	"192.168.122.123"
# )

clusterVMs=(
	"kc1"
	"kw1"
	"kw2"
)

pacclust() {
	if ssh-add -l | grep -q 'id_rsa'; then
		echo "there is a key loaded"
		printf '%s\n' "${clusterVMs[@]}"
		for i in "${clusterVMs[@]}"; do
			echo "root@$i"
			ssh "root@$i" "pacman -Suy --noconfirm" </dev/null
		done
	else
		echo "No root key which is una key"
	fi
}

kup() {
	systemctl is-active libvirtd >/dev/null || {
		echo starting libvirtd...
		sudo systemctl start libvirtd
	}
	sleep 3
	if systemctl is-active libvirtd; then
		for node in "${clusterVMs[@]}"; do
			echo "Starting ${clusterVM[@]}..."
			sudo virsh start "${node}"
		done
	fi
}

kdown() {
	if systemctl is-active libvirtd; then
		for node in "${clusterVMs[@]}"; do
			echo "Destroying ${clusterVM[@]}..."
			sudo virsh destroy "${node}"
		done
	fi
}
