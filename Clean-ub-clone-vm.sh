#!/usr/bin/env bash
#
set -xeuo pipefail

sudo rm -f /etc/machine-id /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server
sudo systemctl restart ssh
sudo dbus-uuidgen --ensure=/etc/machine-id
sudo ssh-keygen -A
