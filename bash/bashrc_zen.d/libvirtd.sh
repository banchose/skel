startvirt() {
	sudo systemctl start libvirtd && sudo virsh start cp
	sudo virsh start wrk1
	sudo virsh start wrk2
	echo hello
}

clusterVMs=(
	"192.168.122.120"
	"192.168.122.121"
	"192.168.122.122"
	"192.168.122.123"
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

upclust() {
	systemctl is-active libvirtd >/dev/null || {
		echo starting libvirtd...
		sudo systemctl start libvirtd
	}
	sleep 3
	if systemctl is-active libvirtd; then
		sudo virsh start cp
		sudo virsh start wrk1
		sudo virsh start wrk2
		sudo virsh start wrk3
	fi
}

downclust() {
	sudo virsh destroy cp
	sudo virsh destroy wrk1
	sudo virsh destroy wrk2
	sudo virsh destroy wrk3
}
