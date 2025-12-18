#!/bin/bash

tag="$1"

ping -q -l 2 -w 3 -c 1 192.168.2.1 >/dev/null &&
	echo '{"text":"UP{$tag:-00}","class":"UP","percentage":100}' ||
	echo '{"text":"DN{$tag:-00}","class":"DOWN","percentage":0}'
