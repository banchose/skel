#!/bin/bash

ping -q -l 2 -w 3 -c 1 192.168.2.1 >/dev/null &&
	echo '{"text":"UP21","class":"UP","percentage":100}' ||
	echo '{"text":"DN21","class":"DOWN","percentage":0}'
