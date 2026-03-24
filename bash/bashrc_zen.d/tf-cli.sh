tf_whisper_transcribe() {
  local file="${1:?Usage: llm_whisper_transcribe <audio_file>}"
  [[ -f "${file}" ]] || {
    printf 'Error: file not found: %s\n' "${file}" >&2
    return 1
  }

  local api_key
  api_key="$(llm keys get tinfoil 2>/dev/null)" || {
    printf 'Error: could not retrieve tinfoil API key\n' >&2
    return 1
  }

  curl -s http://127.0.0.1:8080/v1/audio/transcriptions \
    -F file=@"${file}" \
    -F model=whisper-large-v3-turbo \
    -H "Authorization: Bearer ${api_key}"
}
