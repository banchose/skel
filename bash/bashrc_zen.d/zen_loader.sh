zen_load() {
    # -----------------------------------------------------------------------
    # zen_load — source all *.sh files from ~/.bashrc_zen.d
    # -----------------------------------------------------------------------
    # BASHRC_ZEN_VERBOSE=0  silent (default)
    #                    1  summary only
    #                    2  per-file detail
    #                    3  per-file detail + timing (requires awk)
    # -----------------------------------------------------------------------
    local _dir="${HOME}/.bashrc_zen.d"
    local _verbose="${BASHRC_ZEN_VERBOSE:-0}"
    local _files _file _count=0 _errors=() _syntax_err _t0 _t1

    if [[ ! -d "${_dir}" ]]; then
        echo "zen_load: directory ${_dir} does not exist" >&2
        return 1
    fi

    readarray -t _files < <( shopt -s nullglob; printf '%s\n' "${_dir}"/*.sh )

    (( _verbose >= 1 )) \
        && echo "zen_load: loading ${#_files[@]} files from ${_dir}"

    for _file in "${_files[@]}"; do

        # Broken symlink
        if [[ -L "${_file}" && ! -e "${_file}" ]]; then
            _errors+=("DANGLING SYMLINK: ${_file}")
            (( _verbose >= 2 )) && echo "  ✗ dangling symlink: ${_file##*/}"
            continue
        fi

        # Unreadable file
        if [[ ! -r "${_file}" ]]; then
            _errors+=("NOT READABLE: ${_file}")
            (( _verbose >= 2 )) && echo "  ✗ not readable: ${_file##*/}"
            continue
        fi

        # Syntax check
        if ! _syntax_err=$(bash -n "${_file}" 2>&1); then
            _errors+=("SYNTAX ERROR: ${_file} — ${_syntax_err}")
            (( _verbose >= 2 )) \
                && echo "  ✗ syntax error: ${_file##*/} — ${_syntax_err}"
            continue
        fi

        # Source with optional timing at level 3
        if (( _verbose >= 3 )); then
            _t0="${EPOCHREALTIME}"
            . "${_file}"
            _t1="${EPOCHREALTIME}"
            awk -v t0="${_t0}" -v t1="${_t1}" -v f="${_file##*/}" \
                'BEGIN { printf "  %.3fs  %s\n", t1 - t0, f }'
        else
            (( _verbose >= 2 )) && echo "  ✓ ${_file##*/}"
            . "${_file}"
        fi

        (( ++_count ))

    done

    # Summary
    if (( _verbose >= 1 )); then
        echo "zen_load: sourced ${_count}/${#_files[@]} files"
        if (( ${#_errors[@]} )); then
            echo "zen_load: ${#_errors[@]} error(s):"
            printf "  %s\n" "${_errors[@]}"
        fi
    fi
}
