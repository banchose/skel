getip() {
	(
		cmd='GET / HTTP/1.1\r\nHost: checkip.amazonaws.com\r\nUser-Agent: Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)\r\nAccept: */*\r\nConnection: close\r\n\r\n'
		exec 3<>/dev/tcp/checkip.amazonaws.com/80
		echo -e -n "$cmd" >&3
		cat <&3

	)
}
