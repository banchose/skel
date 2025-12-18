# source
(command -v kubectl &>/dev/null && command -v jq &>/dev/null) || {
	echo "Required commands not found"
	return 0
}

k_get_ingress() {

	# Use fzf to select an ingress by name from the default namespace
	ingress="$(kubectl get ingress -n default -o custom-columns=NAME:.metadata.name --no-headers | fzf)"

	# If an ingress was selected, fetch its configuration and extract path details
	if [ -n "$ingress" ]; then
		kubectl get ingress "$ingress" -n default -o json | jq '.spec.rules[]?.http.paths[]?'
	else
		echo "No ingress selected."
	fi
}
