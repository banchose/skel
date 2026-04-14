## Tinfoil Models
# deepseek-r1-0528
# kimi-k2-5
# gpt-oss-120b
# llama3-3-70b

# tf is just a alias to llm and this is not llm centric
# command -v tf &>/dev/null || return 0

# Was: curl -fsSL https://github.com/tinfoilsh/tinfoil-cli/raw/main/install.sh | sh

alias tf_help_zathura='tf -f ~/gitdir/skel/zathura/zathura-help.md'

tf_test_llm() {
  curl -sS https://inference.tinfoil.sh/v1/chat/completions -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
  "model": "kimi-k2-5",
  "messages": [{"role": "user", "content": "This is just a test"}],
  "temperature": 0
}'
}

tf_get_docs_md() {
  curl -s https://docs.tinfoil.sh/llms-full.txt -o tinfoil-docs-full.md
}

tf_whisper_transcribe() {
  local file="${1:?Usage: tf_whisper_transcribe <audio_file>}"
  local segment_time="${2:-600}"
  local port=8087
  local max_bytes=25000000

  [[ -f "${file}" ]] || {
    printf >&2 'Error: file not found: %s\n' "${file}"
    return 1
  }

  local api_key
  api_key="$(llm keys get tinfoil 2>/dev/null)" ||
    {
      printf >&2 'Error: could not retrieve tinfoil API key (run: llm keys set tinfoil)\n'
      return 1
    }

  type ffmpeg >/dev/null 2>&1 ||
    {
      printf >&2 'Error: ffmpeg not found\n'
      return 1
    }

  curl -sf --connect-timeout 4 "http://localhost:${port}/health" >/dev/null 2>&1 ||
    {
      printf >&2 'Tinfoil proxy not running on port %s. Start it with: tf\n' "${port}"
      return 1
    }

  local tmpdir
  tmpdir="$(mktemp -d)" || return 1
  # NO trap — explicit cleanup via command rm (bypasses rm -v alias)

  local mp3_file="${tmpdir}/audio.mp3"
  if [[ "${file##*.}" == [Mm][Pp]3 ]]; then
    mp3_file="${file}"
  else
    printf >&2 'Converting to mp3...\n'
    if ! ffmpeg -hide_banner -loglevel error -y -i "${file}" -vn -b:a 64k "${mp3_file}"; then
      printf >&2 'Error: ffmpeg conversion failed\n'
      command rm -rf "${tmpdir}"
      return 1
    fi
  fi

  local file_size
  file_size="$(stat --printf='%s' "${mp3_file}" 2>/dev/null || stat -f '%z' "${mp3_file}")" || {
    printf >&2 'Error: could not stat %s\n' "${mp3_file}"
    command rm -rf "${tmpdir}"
    return 1
  }

  local -a chunks=()

  if ((file_size <= max_bytes)); then
    chunks=("${mp3_file}")
  else
    printf >&2 'File exceeds 25MB (%s bytes), splitting into %ds segments...\n' "${file_size}" "${segment_time}"
    if ! ffmpeg -hide_banner -loglevel error -y \
      -i "${mp3_file}" -f segment -segment_time "${segment_time}" -c copy \
      "${tmpdir}/chunk-%03d.mp3"; then
      printf >&2 'Error: ffmpeg split failed\n'
      command rm -rf "${tmpdir}"
      return 1
    fi
    readarray -t chunks < <(printf '%s\n' "${tmpdir}"/chunk-*.mp3 | sort)
    if ((${#chunks[@]} == 0)); then
      printf >&2 'Error: no chunks produced\n'
      command rm -rf "${tmpdir}"
      return 1
    fi
    printf >&2 'Transcribing %d chunks...\n' "${#chunks[@]}"
  fi

  local i=0
  for chunk in "${chunks[@]}"; do
    ((++i))
    ((${#chunks[@]} > 1)) && printf >&2 '[chunk %d/%d]\n' "${i}" "${#chunks[@]}"
    if ! curl -sf "http://127.0.0.1:${port}/v1/audio/transcriptions" \
      -F file=@"${chunk}" \
      -F model=whisper-large-v3-turbo \
      -H "Authorization: Bearer ${api_key}"; then
      printf >&2 'Error: transcription request failed on chunk %d (curl exit: %d)\n' "${i}" "$?"
      command rm -rf "${tmpdir}"
      return 1
    fi
    printf '\n'
  done

  command rm -rf "${tmpdir}"
}

# tinfoil-transcribe() {
#   curl -s http://127.0.0.1:8080/v1/audio/transcriptions \
#     -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
#     -F file=@"$1" \
#     -F model=whisper-large-v3-turbo | jq -r '.text'
# }

tf_start_proxy() {

  tinfoil proxy \
    -r tinfoilsh/confidential-model-router \
    -e inference.tinfoil.sh \
    -p 8080 >/dev/null 2>&1 &
}

tf_curl() {

  local tinfoil_model=kimi-k2-5

  curl -X POST https://inference.tinfoil.sh/v1/chat/completions \
    -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
    "model": "'"${tinfoil_model}"'",
    "messages": [{"role": "user", "content": "Hello world"}]
  }'
}

tf_curl_local() {

  local tinfoil_model=kimi-k2-5

  curl -X POST http://localhost:8080/v1/chat/completions \
    -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
    -H "Content-Type: application/json" \
    -d '{
    "model": "'"${tinfoil_model}"'",
    "messages": [{"role": "user", "content": "This is a test.  Respond with 'OK'"}]
  }'
}

tf_list_models() {

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

edittf() {
  "${EDITOR}" ~/gitdir/skel/bash/bashrc_zen.d/tinfoil-helpers.sh
}

tf_help() {

  cat <<'EOF'
curl http://127.0.0.1:8080/v1/models
EOF
}

echo "BASH COMPLETIONS: added for tinfoil"
source <(tinfoil completion bash)
