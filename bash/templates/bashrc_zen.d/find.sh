# Sourced

function fg() {

	[[ -z $1 ]] && {
		echo "Missing search parameter"
		return 1
	}

	find . -path './gitdir' -prune -o -name "$fileName" -print

}

function finddsk() {

	find /sys/devices -type f -name model -exec cat {} \;

}
