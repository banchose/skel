#!/usr/bin/env bash

set -euo pipefail
set -x

# 1) create a 100GB Ubuntu server template
# 1) Make sure swap is off: systemctl -t swap ?
# 2) make sure containerd is using SystemCgourp = true
# 3) make sure containerd is using /etc/containerd/toml
# 4) (later) kubeadm config images pull

### Start here after VM creatiog ###
# Change ip
# # sudo vim /etc/netplan/blah
# Change hostname
# # sudo hostnamectl hostname alb-blah-blah
# # sudo vim /etc/hosts
# Verify ssh to node
# # sudo systemctl --now enable sshd
# scp installscript to new kuberntes node
#
# Set the version

#####
#
# READ
#
#####

# It looks like you get apt key for the kubernetes repo.  Then you add that repo
# and that ends up in the file /etc/apt/sources.list.d/kubernetes.list
# and the repo is what that determines what version of 'kubernetes' packages you install
# echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# version=1.29.4-00

# remove machine-id and ssh host keys
sudo rm /etc/ssh/ssh_host_*
sudo ssh-keygen -A
sudo rm /etc/machine-id
sudo dbus-uuidgen --ensure=/etc/machine-id

# remove docker-ce
set +e
sudo systemctl stop docker
sudo apt-get purge -y docker-ce
sudo apt-get purge -y docker
sudo rm -rf /var/lib/docker
set -e

# sudo pacman -S docker --needed --noconfirm
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# sudo install -o root -g root -m 644 ./kubernetes-archive-keyring.gpg /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt-get -y dist-upgrade
sudo apt-get install -y apt-transport-https ca-certificates curl ripgrep fd-find fzf
sudo apt-get install -y containerd
sudo apt-get install -y bat curl silversearcher-ag git bash-completion jq fzf bc wget qalc ripgrep pigz fd-find tmux socat
# sudo apt-get install -y kubelet="${version}" kubeadm="${version}" kubectl="${version}" kubernetes-cni
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl
sudo apt-get -y autoremove

[[ -e /etc/modules-load.d/k8s.conf ]] && sudo rm -f /etc/modules-load.d/k8s.conf

sudo sed -i.sed '/^\/swap/ s/^/#/' /etc/fstab

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
[[ -e /etc/sysctl.d/k8s.conf ]] && sudo rm -f /etc/sysctl.d/k8s.conf

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
sudo systemctl mask dev-zram0.swap
sudo swapoff -a
# Re-create the /etc/containerd dir and populate
[[ -d /etc/containerd ]] && sudo mv /etc/containerd /etc/containerd.old
sudo mkdir /etc/containerd

sudo bash -c 'containerd config default >| /etc/containerd/config.toml'
[[ -e /etc/containerd/config.toml ]] && sudo sed -i '/SystemdCgroup/s/false/true/' /etc/containerd/config.toml

if systemctl is-active containerd.service --quiet; then sudo systemctl restart containerd.service; fi
sudo systemctl --now enable containerd
sudo systemctl --now enable kubelet

# remove machine-id and ssh host keys
sudo rm /etc/ssh/ssh_host_*
sudo ssh-keygen -A
sudo rm /etc/machine-id
sudo dbus-uuidgen --ensure=/etc/machine-id

sudo journalctl --rotate
sudo journalctl --vacuum-time=1s

sudo systemctl --now disable ModemManager.service
sudo systemctl --now disable multipathd.service

# kubeadm config images pull

# Change the host name
# sudo hostnamectl hostname "$"

printf "%s\n" "You may want to ssh to run 'kubeadm init --pod-network-cidr=10.244.0.0/16'"
printf "%s\n" "in order to copy the token"
