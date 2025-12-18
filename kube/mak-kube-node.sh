#!/usr/bin/env bash

set -euo pipefail
set -x

version=1.29.4-00

# Add Kubernetes APT repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.lis#t

# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Download and add the GPG key for Kubernetes packages
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
#curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
# sudo install -o root -g root -m 644 ./kubernetes-archive-keyring.gpg /usr/share/keyrings/kubernetes-archive-keyring.gpg

# Update APT and install Kubernetes components
sudo apt update
sudo apt-get install -y curl software-properties-common apt-transport-https ca-certificates git jq
sudo apt-get install -y kubelet kubeadm kubectl containerd
sudo apt-mark hold kubelet kubeadm kubectl

# Remove unnecessary packages
sudo apt-get autoremove -y

# Disable unnecessary services
sudo systemctl disable --now ModemManager.service multipathd.service
# sudo systemctl stop apparmor && sudo systemctl disable apparmor

# Disable swap - required by Kubernetes
sudo swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab

# Load required kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Apply sysctl params required by Kubernetes
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system

# Configure containerd to use systemd as the cgroup driver
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# Remove and regenerate machine-id and ssh host keys
sudo rm -f /etc/machine-id /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo systemctl restart ssh
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo ssh-keygen -A

# Disable unnecessary services
sudo systemctl disable --now ModemManager.service multipathd.service

# Additional cleanup and configurations as required
sudo systemctl enable kubelet

### END
#
echo "You may want to run: sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
