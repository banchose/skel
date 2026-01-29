# wsl ubuntu uses systemd-resolved
# That will look in /etc/systemd/netwwork/ for `.network` file
#
# cat /etc/systemd/network/wsl-net.network
## [Match]
## Name=eth0
##
## [Network]
## DHCP=yes
## DNS=10.1.100.100 10.1.100.101
## Domains=corp.healthresearch.org dz.corp.healthresearch.org

wsl-add-aws() {
  echo "adding to resolv.conf search: corp.healthresearch.org dz.corp.healthresearch.org aws.healthresearch.org"
  sudo resolvectl domain eth0 corp.healthresearch.org dz.corp.healthresearch.org aws.healthresearch.org
}
