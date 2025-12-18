# Logging
sudo iptables -N logdrop
sudo iptables -A logdrop -m limit --limit 5/m --limit-burst 10 -j LOG
sudo iptables -A logdrop -j DROP

# Allow traffic on loopback
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
#
# # Allow Established and Related Incoming Connections
sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#
# # Allow Established Outgoing Connections
sudo iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED -j ACCEPT
#
# # Allow Internal Network to access External (if applies)
# # sudo iptables -A FORWARD -i eth0 -o eth1 -j ACCEPT
#
# # Drop log Invalid Packets
sudo iptables -A INPUT -m conntrack --ctstate INVALID -j logdrop

# # Drop log icmp pings
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j logdrop

# Drop log http/https
sudo iptables -A INPUT -p tcp --dport 80 -j logdrop
sudo iptables -A INPUT -p tcp --dport 443 -j logdrop
