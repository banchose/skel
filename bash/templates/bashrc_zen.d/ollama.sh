ol () {
	command -v ollama &>/dev/null || {
		echo "ollama is not on path"
		return 1
	}
	command -v  fzf &>/dev/null || {
		echo "fzf is not on path"
		return 1
	}
	model="$(ollama list | fzf --with-nth 1 | cut -f1)"
	echo "Model selected full: $model"
	echo " ollama run ${model%%:*}"
	echo " ollama run ${model}"
	ollama run "${model// */}"
}
