#!/usr/bin/env bash
#
set -euo pipefail

grep -s -i ubuntu /etc/os-release || {
	echo "Are you Ubuntu?"
	exit 1
}
sudo systemctl stop kubelet || echo "kubelet not running"
sudo systemctl disable kubelet || echo "Disabling kubelet was a disaster"
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/kubelet
sudo rm -rf /var/lib/etcd
sudo rm -rf /etc/machine-id
sudo dpkg-reconfigure openssh-server
echo "===================> Change the hostname"
