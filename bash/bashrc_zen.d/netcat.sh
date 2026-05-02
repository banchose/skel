netcat_help() {

  cat <<'EOF'
## A little server by the book
printf 'HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nContent-Length: 4\r\nConnection: close\r\n\r\ntest' >|/tmp/reply
while true; do nc -lp 8088 </tmp/reply; done
EOF
}
