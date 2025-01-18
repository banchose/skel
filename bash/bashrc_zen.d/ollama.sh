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


echo "**** BASH COMPLETION DEFINED ****"
echo "**** ollama bash completion ****"

_complete_ollama() {
    local cur prev words cword
    _init_completion -n : || return

    if [[ ${cword} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "serve create show run push pull list ps cp rm help" -- "${cur}"))
    elif [[ ${cword} -eq 2 ]]; then
        case "${prev}" in
            (run|show|cp|rm|push|list)
                WORDLIST=$((ollama list 2>/dev/null || echo "") | tail -n +2 | cut -d "	" -f 1)
                COMPREPLY=($(compgen -W "${WORDLIST}" -- "${cur}"))
                __ltrim_colon_completions "$cur"
                ;;
        esac
    fi
}
complete -F _complete_ollama ollama

qo() {
  obj='{
    "model": "olmo2:13b",
    "messages": [
      {
        "role": "user",
        "content": "'"$1"'"
      }
    ],
    "stream": false
  }'
  ssh cube "curl -s http://localhost:11434/api/chat -H "Content-Type: application/json" -d '$obj'" | jq -r '.message.content'
}

