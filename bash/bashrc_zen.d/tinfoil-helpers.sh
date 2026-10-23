# shellcheck shell=bash
# shellcheck disable=SC2030,SC2031  # subshell-scoped tmpdir + EXIT trap is intentional
# tinfoil-helpers.sh — sourced from bashrc.d. Not a standalone script: no
# set -e here (it would leak into the interactive shell); every function
# checks its own exit statuses.
#
# Requires: curl, jq. Transcription also needs ffmpeg, ffprobe.
# Keys come from the environment only (TINFOIL_API_KEY), never prompted or stored.
#
# Functions
#   tf_proxy_ensure              start tinfoil-proxy on $TF_PORT if not already up
#   tf_proxy_stop                kill it
#   tf_proxy_install             download + sha256-verify + install to ~/.local/bin
#   tf_smoke [model]             one chat completion through the proxy
#   tf_list_models               model ids via the proxy
#   tf_whisper_transcribe FILE [segment_seconds]
#
# History: transcribe v1 split by bytes (25 MB); the endpoint actually limits
# *duration*, hence ffprobe + 570 s chunks. whisper-large-v3-turbo is billed
# per request, so bigger chunks are cheaper.

: "${TF_PORT:=8087}"
: "${TF_MODEL:=kimi-k3}"
: "${TF_PROXY_INSTALL_DIR:=${HOME}/.local/bin}"

_tf_base() { printf 'http://127.0.0.1:%s' "${TF_PORT}"; }

# /health returns 200 on tinfoil-proxy >= 0.2.7 (verified 2026-10-22).
_tf_proxy_up() {
    curl -sf --connect-timeout 1 -o /dev/null "$(_tf_base)/health"
}

_tf_require() {
    local -a missing=()
    local cmd
    for cmd in "$@"; do
        command -v "${cmd}" >/dev/null 2>&1 || missing+=("${cmd}")
    done
    if (( ${#missing[@]} )); then
        printf >&2 'missing required commands: %s\n' "${missing[*]}"
        return 1
    fi
}

_tf_key() {
    if [[ -z ${TINFOIL_API_KEY:-} ]]; then
        printf >&2 'TINFOIL_API_KEY is not set\n'
        return 1
    fi
}

# Print the API's error message if the body has one, else the first 2000 bytes.
_tf_show_error() {
    local body_file=$1
    jq -er '.error.message // .error // empty' "${body_file}" >&2 2>/dev/null ||
        head -c 2000 "${body_file}" >&2
    printf >&2 '\n'
}

# ---------------------------------------------------------------------------
# proxy
# ---------------------------------------------------------------------------

# Upstream install.sh greps the release JSON for "tag_name" and breaks when the
# release *body* contains that string (v0.2.7 did). Do it properly with jq,
# verify against the asset digest api.github.com publishes, then install.
tf_proxy_install() {
    _tf_require curl jq || return 1

    local os arch
    case "$(uname -s)" in
        Linux)  os=linux ;;
        Darwin) os=darwin ;;
        *)      printf >&2 'unsupported OS: %s\n' "$(uname -s)"; return 1 ;;
    esac
    case "$(uname -m)" in
        x86_64)        arch=amd64 ;;
        aarch64|arm64) arch=arm64 ;;
        *)             printf >&2 'unsupported arch: %s\n' "$(uname -m)"; return 1 ;;
    esac
    local asset="tinfoil-proxy-${os}-${arch}"

    local api="https://api.github.com/repos/tinfoilsh/tinfoil-proxy/releases/latest"
    [[ -n ${TF_PROXY_VERSION:-} ]] &&
        api="https://api.github.com/repos/tinfoilsh/tinfoil-proxy/releases/tags/v${TF_PROXY_VERSION#v}"

    local release tag digest
    release=$(curl -fsSL -H 'Accept: application/vnd.github+json' "${api}") || {
        printf >&2 'could not fetch release metadata from %s\n' "${api}"
        return 1
    }
    tag=$(jq -er '.tag_name' <<< "${release}") || {
        printf >&2 'release JSON has no tag_name\n'
        return 1
    }
    digest=$(jq -er --arg a "${asset}" \
        '.assets[] | select(.name == $a) | .digest | ltrimstr("sha256:")' <<< "${release}") || {
        printf >&2 'no sha256 digest published for %s in %s\n' "${asset}" "${tag}"
        return 1
    }
    [[ ${digest} =~ ^[0-9a-f]{64}$ ]] || {
        printf >&2 'digest for %s does not look like sha256: %s\n' "${asset}" "${digest}"
        return 1
    }

    printf >&2 'tinfoil-proxy %s (%s) -> %s/tinfoil-proxy\n' "${tag}" "${asset}" "${TF_PROXY_INSTALL_DIR}"
    local answer
    read -rp 'Proceed? [y/N] ' answer
    [[ ${answer,,} == y ]] || return 1

    (
        local tmpdir
        trap 'command rm -rf "${tmpdir:-}"' EXIT   # command: host has an rm alias
        tmpdir=$(mktemp -d) || exit 1
        cd "${tmpdir}" || exit 1

        curl -fsSLO "https://github.com/tinfoilsh/tinfoil-proxy/releases/download/${tag}/${asset}" || {
            printf >&2 'download failed\n'
            exit 1
        }
        if command -v sha256sum >/dev/null 2>&1; then
            printf '%s  %s\n' "${digest}" "${asset}" | sha256sum -c - >/dev/null
        else
            printf '%s  %s\n' "${digest}" "${asset}" | shasum -a 256 -c - >/dev/null
        fi || {
            printf >&2 'sha256 mismatch — not installed\n'
            exit 1
        }
        mkdir -p "${TF_PROXY_INSTALL_DIR}" &&
            install -m 0755 "${asset}" "${TF_PROXY_INSTALL_DIR}/tinfoil-proxy" || {
            printf >&2 'install to %s failed\n' "${TF_PROXY_INSTALL_DIR}"
            exit 1
        }
        printf >&2 'installed %s\n' "${TF_PROXY_INSTALL_DIR}/tinfoil-proxy"
    ) || return 1
    hash -r
}

tf_proxy_ensure() {
    _tf_proxy_up && return 0
    _tf_require curl || return 1

    if ! command -v tinfoil-proxy >/dev/null 2>&1; then
        printf >&2 'tinfoil-proxy is not installed\n'
        tf_proxy_install || return 1
    fi

    local log_file="${XDG_RUNTIME_DIR:-/tmp}/tinfoil-proxy.log"
    local pid
    # Started inside $( ) so it is not a job of this shell: no [1] PID / Exit noise.
    # >| : the host shell runs with noclobber; a plain > fails if the log exists.
    pid=$(
        tinfoil-proxy -p "${TF_PORT}" >|"${log_file}" 2>&1 &
        printf '%s' "$!"
    )

    local -i attempts=0
    until _tf_proxy_up; do
        if ! kill -0 "${pid}" 2>/dev/null; then
            printf >&2 'tinfoil-proxy exited during startup (log: %s):\n' "${log_file}"
            tail -n 20 "${log_file}" >&2
            return 1
        fi
        if (( ++attempts >= 20 )); then
            printf >&2 'tinfoil-proxy not ready after 10s (log: %s)\n' "${log_file}"
            return 1
        fi
        sleep 0.5
    done
}

tf_proxy_stop() {
    pkill -x tinfoil-proxy || printf >&2 'tinfoil-proxy not running\n'
}

# ---------------------------------------------------------------------------
# diagnostics
# ---------------------------------------------------------------------------

tf_smoke() {
    local model="${1:-${TF_MODEL}}"
    _tf_require curl jq && _tf_key && tf_proxy_ensure || return 1

    local body_file http_code
    body_file=$(mktemp) || return 1
    http_code=$(curl -sS --max-time 120 -o "${body_file}" -w '%{http_code}' \
        "$(_tf_base)/v1/chat/completions" \
        -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
        -H 'Content-Type: application/json' \
        --data-binary "$(jq -n --arg m "${model}" '{
            model: $m,
            messages: [{role: "user", content: "This is a test. Respond with OK."}],
            max_tokens: 4096
        }')")   # reasoning tokens count against max_tokens; 64 gave null content
    local rc=$?
    if (( rc != 0 )) || [[ ${http_code} != 2?? ]]; then
        printf >&2 '%s: HTTP %s (curl exit %d)\n' "${model}" "${http_code}" "${rc}"
        _tf_show_error "${body_file}"
        command rm -f "${body_file}"
        return 1
    fi
    # Empty content on a 2xx usually means the reasoning budget was exhausted.
    jq -r '.choices[0] as $c
        | ($c.message.content // "") as $t
        | if ($t | length) > 0 then $t
          else "(no content: finish_reason=\($c.finish_reason), reasoning_chars=\($c.message.reasoning // "" | length), completion_tokens=\(.usage.completion_tokens))"
          end' "${body_file}"
    command rm -f "${body_file}"
}

tf_list_models() {
    _tf_require curl jq && _tf_key && tf_proxy_ensure || return 1
    curl -sfS "$(_tf_base)/v1/models" -H "Authorization: Bearer ${TINFOIL_API_KEY}" |
        jq -r '.data[].id' | sort
}

# ---------------------------------------------------------------------------
# transcription
# ---------------------------------------------------------------------------

tf_whisper_transcribe() {
    local file="${1:?Usage: tf_whisper_transcribe <audio_file> [segment_seconds]}"
    local segment_time="${2:-570}"
    local model='whisper-large-v3-turbo'
    local req_timeout=900

    [[ -f ${file} ]] || {
        printf >&2 'file not found: %s\n' "${file}"
        return 1
    }
    if ! [[ ${segment_time} =~ ^[1-9][0-9]*$ ]]; then
        printf >&2 'segment_seconds must be a positive integer: %s\n' "${segment_time}"
        return 1
    fi
    _tf_require ffmpeg ffprobe curl jq && _tf_key && tf_proxy_ensure || return 1

    # Subshell + EXIT trap: tmpdir is removed on success, error, and Ctrl-C,
    # and `exit` inside acts as an early return without killing the shell.
    (
        local tmpdir
        trap 'command rm -rf "${tmpdir:-}"' EXIT
        tmpdir=$(mktemp -d) || exit 1

        # --- normalise to mp3 ---------------------------------------------
        local mp3_file="${tmpdir}/audio.mp3"
        if [[ ${file##*.} == [Mm][Pp]3 ]]; then
            mp3_file=${file}
        else
            printf >&2 'Converting to mp3...\n'
            ffmpeg -hide_banner -loglevel error -y -i "${file}" -vn -b:a 64k "${mp3_file}" || {
                printf >&2 'ffmpeg conversion failed\n'
                exit 1
            }
        fi

        # --- duration (the endpoint limits duration, not bytes) ------------
        local duration
        duration=$(ffprobe -v error -show_entries format=duration \
            -of default=noprint_wrappers=1:nokey=1 "${mp3_file}") || {
            printf >&2 'ffprobe failed on %s\n' "${mp3_file}"
            exit 1
        }
        duration=${duration%%.*}
        [[ ${duration} =~ ^[0-9]+$ ]] || {
            printf >&2 'could not determine duration (ffprobe gave: %s)\n' "${duration}"
            exit 1
        }

        # --- split if needed ----------------------------------------------
        local -a chunks=()
        if (( duration <= segment_time )); then
            chunks=("${mp3_file}")
        else
            printf >&2 'Audio is %ds (limit %ds), splitting...\n' "${duration}" "${segment_time}"
            ffmpeg -hide_banner -loglevel error -y -i "${mp3_file}" \
                -f segment -segment_time "${segment_time}" -reset_timestamps 1 \
                -c copy "${tmpdir}/chunk-%03d.mp3" || {
                printf >&2 'ffmpeg split failed\n'
                exit 1
            }
            shopt -s nullglob
            chunks=("${tmpdir}"/chunk-*.mp3)   # zero-padded, so glob order is correct
            shopt -u nullglob
            (( ${#chunks[@]} )) || {
                printf >&2 'no chunks produced\n'
                exit 1
            }
            printf >&2 'Transcribing %d chunks...\n' "${#chunks[@]}"
        fi

        # --- transcribe ---------------------------------------------------
        local chunk body_file http_code rc
        local -i i=0
        for chunk in "${chunks[@]}"; do
            i+=1
            (( ${#chunks[@]} > 1 )) && printf >&2 '[chunk %d/%d]\n' "${i}" "${#chunks[@]}"
            body_file="${tmpdir}/resp-${i}.json"

            http_code=$(curl -sS --max-time "${req_timeout}" \
                -o "${body_file}" -w '%{http_code}' \
                "$(_tf_base)/v1/audio/transcriptions" \
                -H "Authorization: Bearer ${TINFOIL_API_KEY}" \
                -F file=@"${chunk}" \
                -F model="${model}" \
                -F response_format=json)
            rc=$?
            if (( rc != 0 )); then
                printf >&2 'curl failed on chunk %d/%d (exit %d)\n' "${i}" "${#chunks[@]}" "${rc}"
                exit 1
            fi
            if [[ ${http_code} != 2?? ]]; then
                printf >&2 'chunk %d/%d returned HTTP %s\n' "${i}" "${#chunks[@]}" "${http_code}"
                _tf_show_error "${body_file}"
                exit 1
            fi
            jq -er '.text' "${body_file}" || {
                printf >&2 'chunk %d/%d returned no .text field\n' "${i}" "${#chunks[@]}"
                head -c 2000 "${body_file}" >&2
                printf >&2 '\n'
                exit 1
            }
        done
    )
}
