docker run --rm -it --name tshark \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  bash:latest

# /usr/sbin/tshark -V -i any tcp port 8080 -d "tcp.port==8080,http" > /tmp/packet.out
