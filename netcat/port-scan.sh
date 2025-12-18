return 1

nc -vz -w 5 127.0.0.0 21 8000-8101 23

# -z: port scan
# -w: timeout in seconds
# -v: verbose
# range with additional ports 21 and 23
#

# Check if port is up
nc -zvw3 [hostname or ip] [port]
