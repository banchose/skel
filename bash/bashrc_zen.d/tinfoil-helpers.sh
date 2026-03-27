## Tinfoil Models
# deepseek-r1-0528
# kimi-k2-5
# gpt-oss-120b
# llama3-3-70b

# tf is just a alias to llm and this is not llm centric
# command -v tf &>/dev/null || return 0

alias tf_help_zathura='tf -f ~/gitdir/skel/zathura/zathura-help.md'

tin_test_llm() {
  curl -sS https://inference.tinfoil.sh/v1/chat/completions -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "model": "kimi-k2-5",
  "messages": [{"role": "user", "content": "This is just a test"}],
  "temperature": 0
}'
}

tinfoil_get_docs_md() {
  curl -s https://docs.tinfoil.sh/llms-full.txt -o tinfoil-docs-full.md
}

tinfoil-transcribe() {
  curl -s http://127.0.0.1:8080/v1/audio/transcriptions \
    -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -F file=@"$1" \
    -F model=whisper-large-v3-turbo | jq -r '.text'
}

tinfoil_start_proxy() {

  tinfoil proxy \
    -r tinfoilsh/confidential-model-router \
    -e inference.tinfoil.sh \
    -p 8080 >/dev/null 2>&1 &
}

tinfoil_curl() {

  local tinfoil_model=kimi-k2-5

  curl -X POST https://inference.tinfoil.sh/v1/chat/completions \
    -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
    "model": "'"${tinfoil_model}"'",
    "messages": [{"role": "user", "content": "Hello world"}]
  }'
}

tinfoil_list_models() {

  curl https://inference.tinfoil.sh/v1/models \
    -H "Authorization: Bearer ${TINFOIL_API_KEY}"
}

tf_llm_img() {
  local prompt="$1"
  local tmpfile
  tmpfile=$(mktemp --suffix=.jpg)
  wl-paste --type image/png | magick png:- -resize '2000x2000>' -quality 85 "$tmpfile"
  llm -t tin "$prompt" -a "$tmpfile"
  rm -f "$tmpfile"
}

edittin() {
  "${EDITOR}" ~/gitdir/skel/bash/bashrc_zen.d/tinfoil-helpers.sh
}

echo "BASH COMPLETIONS: added for tinfoil"
source <(tinfoil completion bash)
