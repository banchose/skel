#!/usr/bin/env bash

set -euo pipefail

sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.2.2/24
sudo nmcli connection modify "Wired connection 1" ipv4.gateway 192.168.2.1
sudo nmcli connection modify "Wired connection 1" ipv4.dns "9.9.9.9 149.112.112.112"
sudo nmcli connection modify "Wired connection 1" ipv4.method manual
sudo nmcli connection up "Wired connection 1" 

# && sleep 160 && sudo nmcli connection modify "Wired connection 1" ipv4.method auto
