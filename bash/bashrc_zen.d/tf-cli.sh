# tf_whisper_transcribe() {
#   local file="${1:?Usage: llm_whisper_transcribe <audio_file>}"
#   [[ -f "${file}" ]] || {
#     printf 'Error: file not found: %s\n' "${file}" >&2
#     return 1
#   }
#
#   local api_key
#   api_key="$(llm keys get tinfoil 2>/dev/null)" || {
#     printf 'Error: could not retrieve tinfoil API key\n' >&2
#     return 1
#   }
#
#   curl -s http://127.0.0.1:8080/v1/audio/transcriptions \
#     -F file=@"${file}" \
#     -F model=whisper-large-v3-turbo \
#     -H "Authorization: Bearer ${api_key}"
# }

tf_whisper_transcribe() {
  local file="${1:?Usage: tf_whisper_transcribe <audio_file>}"
  [[ -f "${file}" ]] || {
    printf 'Error: file not found: %s\n' "${file}" >&2
    return 1
  }

  local api_key
  api_key="$(llm keys get tinfoil 2>/dev/null)" || {
    printf 'Error: could not retrieve tinfoil API key\n' >&2
    return 1
  }

  local max_bytes=25000000
  local file_size
  file_size="$(stat --printf='%s' "${file}" 2>/dev/null || stat -f '%z' "${file}" 2>/dev/null)" || {
    printf 'Error: could not determine file size\n' >&2
    return 1
  }

  if ((file_size <= max_bytes)); then
    curl -s http://127.0.0.1:8080/v1/audio/transcriptions \
      -F file=@"${file}" \
      -F model=whisper-large-v3-turbo \
      -H "Authorization: Bearer ${api_key}"
    return
  fi

  printf 'File exceeds 25MB (%s bytes), splitting...\n' "${file_size}" >&2

  local tmpdir
  tmpdir="$(mktemp -d)" || {
    printf 'Error: could not create temp directory\n' >&2
    return 1
  }
  trap 'rm -rf "${tmpdir}"' RETURN

  command -v ffmpeg >/dev/null 2>&1 || {
    printf 'Error: ffmpeg not found (required for splitting)\n' >&2
    return 1
  }

  local ext="${file##*.}"
  ffmpeg -hide_banner -loglevel warning \
    -i "${file}" \
    -f segment -segment_time 600 -c copy \
    "${tmpdir}/chunk-%03d.${ext}" || {
    printf 'Error: ffmpeg split failed\n' >&2
    return 1
  }

  local chunks
  readarray -t chunks < <(printf '%s\n' "${tmpdir}"/chunk-*.${ext} | sort)

  if ((${#chunks[@]} == 0)); then
    printf 'Error: no chunks produced\n' >&2
    return 1
  fi

  printf 'Transcribing %d chunks...\n' "${#chunks[@]}" >&2

  local i=0
  for chunk in "${chunks[@]}"; do
    ((++i))
    printf '[chunk %d/%d] %s\n' "${i}" "${#chunks[@]}" "${chunk##*/}" >&2
    curl -s http://127.0.0.1:8080/v1/audio/transcriptions \
      -F file=@"${chunk}" \
      -F model=whisper-large-v3-turbo \
      -H "Authorization: Bearer ${api_key}"
    printf '\n'
  done
}
