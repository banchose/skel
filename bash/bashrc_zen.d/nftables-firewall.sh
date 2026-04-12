nft_create() {
  # Load rules into memory only (not persisted)
  sudo nft flush ruleset
  sudo nft add table inet filter
  sudo nft add chain inet filter input '{ type filter hook input priority 0; policy accept; }'
  sudo nft add rule inet filter input ct state established,related accept
  sudo nft add rule inet filter input iif lo accept
  sudo nft add rule inet filter input meta l4proto icmp accept
  sudo nft add rule inet filter input meta l4proto ipv6-icmp accept
  sudo nft add rule inet filter input tcp dport 22 accept
  # sudo nft add rule inet filter input udp dport 53 accept
  # sudo nft add rule inet filter input tcp dport 53 accept
  sudo nft chain inet filter input '{ policy drop; }'
  sudo nft list ruleset # review
  read -rn 1 -p "Continue? [y/N] " answer
  echo # newline after the single character
  [[ "${answer}" =~ ^[yY]$ ]] || {
    echo "Not making permenent"
    return 1
  }
  sudo nft list ruleset | sudo tee /etc/nftables.conf
  sudo systemctl enable nftables # persist across reboots
}
