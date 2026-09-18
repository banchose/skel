#!/usr/bin/env bash
# link-bashrc-zen.sh - populate ~/.bashrc_zen.d with symlinks into the skel repo
set -uo pipefail

SRC="${HOME}/gitdir/skel/bash/bashrc_zen.d"
DST="${HOME}/.bashrc_zen.d"

LINKS=(
    ai.sh
    aws.sh
    aws-bedrock.sh
    aws-costs.sh
    aws-rds.sh
    aws-waf.sh
    bash_misc.sh
    docker.sh
    git.sh
    hri-attmove-deploy-helper.sh
    hri-git.sh
    hri-pisal-deploy-helper.sh
    kubernetes.sh
    llm-cli.sh
    nvim.sh
    nvim_chooser.sh
    openwebui.sh
    pi-agent.sh
    tinfoil-helpers.sh
    unmanaged-upgrades.sh
    zen_functions.sh
)

DRYRUN=0
[[ "${1:-}" == "-n" || "${1:-}" == "--dry-run" ]] && DRYRUN=1

if [[ ! -d "$SRC" ]]; then
    echo "ERROR: source dir not found: $SRC" >&2
    echo "       clone the skel repo first." >&2
    exit 1
fi

mkdir -p "$DST" || exit 1

created=0 skipped=0 problems=0

for name in "${LINKS[@]}"; do
    src="$SRC/$name"
    link="$DST/$name"

    if [[ ! -e "$src" ]]; then
        printf 'MISSING %s not in repo - skipped\n' "$name"
        ((problems++))
        continue
    fi

    if [[ -L "$link" ]]; then
        if [[ "$(readlink -f "$link")" == "$(readlink -f "$src")" ]]; then
            printf 'ok      %s (already linked)\n' "$name"
            ((skipped++))
        else
            printf 'WARN    %s points elsewhere: %s\n' "$name" "$(readlink "$link")"
            ((problems++))
        fi
        continue
    fi

    if [[ -e "$link" ]]; then
        printf 'WARN    %s exists as a real file - left alone\n' "$name"
        ((problems++))
        continue
    fi

    if (( DRYRUN )); then
        printf 'would   ln -s %s %s\n' "$src" "$link"
        ((created++))
    elif ln -s "$src" "$link"; then
        printf 'created %s\n' "$name"
        ((created++))
    else
        printf 'FAILED  %s\n' "$name"
        ((problems++))
    fi
done

printf '\n%d created, %d already present, %d needing attention\n' \
    "$created" "$skipped" "$problems"
(( problems > 0 )) && exit 2
exit 0
