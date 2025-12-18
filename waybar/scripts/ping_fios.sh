#!/bin/bash

ping -q -l 2 -w 3 -c 1 192.168.1.1 >/dev/null &&
	echo '{"text":"UP11","class":"UP","percentage":100}' ||
	echo '{"text":"DN11","class":"DOWN","percentage":0}'
