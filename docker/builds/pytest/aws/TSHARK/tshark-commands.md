# tshark Cheat Sheet

```bash
PCAPFILTER="host 172.16.2.2"
tshark -D
tshark -f "${filter}"
```

```sh
tshark -i eth0 host 127.0.0.1
```

```sh
tshark -i eth0 host 127.0.0.1 and port 8080
```

```sh
tshark -Y'http'
tshark -T fields -e http.host -Y "http"
```

```sh
tshark -i eth0 -R 'http.request'
```

```sh
## Show available fields
tshark -G fields
```

## -Y

- Only show packets that have the http.host field present
- Then you can -T fields -e http.host to pick the fields you want displayed

```sh
# only display http.host from 'http' traffic
tshark -T fields -e http.host -Y "http"
```

## Display Fields

Use the `-T fields` each field you want `-e <field>`

```sh
tshark -r capture.pcap -T fields -e ip.src -e tcp.port
```

## Interfaces

```sh
tshark -D
```

## Pipe

```sh
tshark -l -i eth0 -T fields -e dns.qry.name -e dns.qry.type -e dns.a -e dns.aaaa | grep -vP '^\t*$'
```

## Fields

```sh
# example
tshark -G
tshark -G | grep '\sdns\.' | bat
```

## Details

- `-V`: Capital 'V'

```sh
tshark -V -f "not port 22"
```

## Permission denied -w

```sh
sudo dpkg-reconfigure wireshark
```

## Wireshark default format

```sh
tshark.exe -o "gui.column.format:\"Source\",\"%us\",\"Destination\",\"%ud\",\"src port\",\"%S\",\"dest port\",\"%D\"" -r sample_001.cap.pcapng
```

## This!

```sh
tshark --color
```

- Capture filters: `-f` `not port 80`
- Display filter: `tcp.port == 80` `-Y`

## Quick

```sh
/usr/sbin/tshark -V -i any tcp port 8080 -d "tcp.port==8080,http" > /tmp/packet.out
```

## Find Fields

```sh
sudo tshark -T pdml
```

## Filter

- Filter out a lot of low level protos

```sh
sudo tshark -f ip
```

## Print the mac address

### Link

https://www.wireshark.org/docs/dfref/e/eth.html

```sh
sudo tshark -f 'icmp' -e eth.src -Tfields
```

```sh
sudo tshark -f 'not port 22' -Y http.host -T fields -e http.host
```

```

## Filter -f

```

```
# - f 'not port 22': This is your capture filter to exclude traffic on port 22.
# - Y http.host: This is a display filter to only show packets that have an HTTP host field.
# - T fields: This tells tshark to output the specified fields only.
# - e http.host: This specifies the field you want to extract, which in this case is the HTTP


sudo tshark -f 'not port 22' -Y tcp.port -T fields -e tcp.port
```

```
## Capture Filter (pcap filter)

# Apply a DISPLAY filter
tshark -r <file.pcap> -Y <display filter>
-Y 'tcp.dstport == 443'

src net 192.168

host 172.18.5.4
net 192.168.0.0/24
not tcp port 3389
tcp portrange 1501-1549
not broadcast and not multicast
src net 192.168.0.0 mask 255.255.255.0
port 53
port not 53 and not arp
not ether dst 01:80:c2:00:00:0e
ip
vlan
# Range of ports
(tcp[0:2] > 1500 and tcp[0:2] < 1550) or (tcp[2:2] > 1500 and tcp[2:2] < 1550)
# OR
tcp portrange 1501-1549
```
