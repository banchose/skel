#!/usr/bin/env bash

set -euo pipefail

grep -i ubuntu /etc/os-release || {
	echo "Are you Ubuntu?"
	exit 1
}
sudo systemctl stop kubelet || echo "kubelet not running"
sudo systemctl disable kubelet || echo "Disabling kubelet was a disaster"
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/etcd
sudo rm -f /etc/machine-id /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo systemctl restart ssh
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo ssh-keygen -A
echo "===================> Change the hostname"
