# Source
#
#

notepath=~/gitdir/configs/notes/notes.md

not() {

	[[ -f $notepath ]] || {
		echo "$notepath"
		retrun 1
	}
	nvim "$notepath"

}

nota() {

	[[ -f $notepath ]] || {
		echo "$notepath"
		retrun 1
	}
	echo "$1" >>"$notepath"

}
