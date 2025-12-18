function getvue() {
	testURL="https://alb-tst-ingo-1.healthresearch.org/pisal"
	prodURL="https://alb-prd-ingo-1.healthresearch.org/pisal"

	if [[ $# -eq 0 ]]; then
		echo "no arguments"
		exit 1
	fi

	if [[ $1 == "test" ]]; then
		URL="$testURL"
	elif [[ $1 == "prod" ]]; then
		URL="$prodURL"
	else
		echo "Bad parameters - test or prod"
		exit 1
	fi

	miniFile="$(curl -k -L "$URL" | grep -o -E 'index.[[:alnum:]]{8}\.js')"
	if [[ $? -eq 0 ]]; then
		curl -k -L "$URL"/assets/"$miniFile"
		echo "$URL"/"$miniFile"
	else
		echo "Could not curl: $URL"
	fi
}
