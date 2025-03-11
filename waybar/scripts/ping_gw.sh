#!/bin/bash

ping -q -l 2 -w 3 -c 1 108.44.37.1 >/dev/null &&
	echo '{"text":"UPGW","class":"UP","percentage":100}' ||
	echo '{"text":"DNGW","class":"DOWN","percentage":0}'
