#!/usr/bin/env bash

set -uo pipefail

grep -i ubuntu /etc/os-release || {
	echo "Are you Ubuntu?"
	exit 1
}
sudo systemctl stop kubelet || echo "kubelet not running"
sudo systemctl disable kubelet || echo "Disabling kubelet was a disaster"
sudo rm -vrf /etc/kubernetes
sudo rm -vrf /var/lib/kubelet
sudo rm -vrf /var/lib/etcd
sudo rm -vrf /etc/modules-load.d/k8s.conf
sudo rm -vf /etc/machine-id /etc/ssh/ssh_host_*
sudo rm -vrf /root/.kube
sudo rm -vrf /home/*/.kube
sudo dpkg-reconfigure openssh-server
sudo systemctl restart ssh
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo ssh-keygen -A
echo "===================> Change the hostname! Or not"
