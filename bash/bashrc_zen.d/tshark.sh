# tshark -G fields
# tshark -G fields | grep dns.qry

tshark-cap-dns() {
  tshark -l -i eth0 -T fields -e dns.qry.name -e dns.qry.type -e dns.a -e dns.aaaa | grep -vP '^\t*$'
}
