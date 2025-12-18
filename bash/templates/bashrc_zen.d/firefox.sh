ffp() {
	[[ -e ~/.mozilla/firefox/profiles.ini ]] && grep '[Nn]ame' ~/.mozilla/firefox/profiles.ini
}

fireprof-update() {

	local mozPath="${HOME}/.mozilla/firefox"
	local userOverrides="${HOME}/gitdir/configs/firefox/user-overrides.js"

	[[ -d ${mozPath} ]] || {
		echo "Can't find ${mozPath}"
		exit 1
	}
	cd "${mozPath}"

	fireProfs=("${mozPath}"/*/)

	for prof in "${fireProfs[@]}"; do
		if [[ -f "${prof}updater.sh" ]]; then
			cd -- "${prof}" || {
				echo "Could not cd into ${prof}"
				exit 1
			}
			[[ -L "${userOverrides}" ]] && ln -s -- "${userOverrides}"
			./updater.sh -s
		fi
	done

}
