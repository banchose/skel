trouble-dns() {
  echo ""
  echo "##################################"
  echo "Checking DHCP leases if any"
  echo "##################################"
  echo ""
  cat /run/systemd/netif/leases/*
  echo ""
  echo "##################################"
  echo "resolvectl status"
  echo "##################################"
  echo ""
  resolvectl status
  echo ""
  echo "##################################"
  echo "Find UseDomain setting"
  echo "##################################"
  echo ""
  grep -C 2 UseDomain /etc/systemd/networkd.conf
  echo ""
  echo "##################################"
  echo "systemd-networkd journalctl"
  echo "##################################"
  echo ""
  journalctl -b --no-pager -u systemd-networkd
  echo ""
  echo "##################################"
  echo "resolvectl domains"
  echo "##################################"
  echo ""
  resolvectl status | grep 'DNS Domain:'
  grep -C 2 -i -E '(UseDomain|Network)' /etc/systemd/system.conf
}
