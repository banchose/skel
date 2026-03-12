deploy_prod() {
  if [[ $# -lt 2 || $# -gt 3 ]]; then
    printf 'Usage: deploy_prod <app> <env> [<check-string>]\n' >&2
    return 1
  fi

  local -r app="$1"
  local -r env="$2"
  local -r check="${3:-}"
  local -r repo="$HOME/hrigit/Kubernetes"
  local -r yaml="${repo}/${app}/${env}/${app}-deploy-${env}.yaml"
  local ctx

  case "${env}" in
  newprod) ctx="Prod-Admin@Prod" ;;
  awswebprod) ctx="arn:aws:eks:us-east-1:315633532929:cluster/EksProd" ;;
  *)
    printf '❌ Unknown env: %s\n' "${env}" >&2
    return 1
    ;;
  esac

  (
    cd "${repo}" || exit 1

    git pull || exit 1

    if [[ ! -f "${yaml}" ]]; then
      printf '❌ Not found: %s\n' "${yaml}" >&2
      exit 1
    fi

    # Show image tag
    local image_line image_tag
    image_line=$(grep -E '^\s*image:' "${yaml}" | head -1) || true
    if [[ -z "${image_line}" ]]; then
      printf '❌ No image: line found in %s\n' "${yaml##*/}" >&2
      exit 1
    fi
    image_tag="${image_line##*image:}"
    image_tag="${image_tag// /}"
    printf '\n  image: %s  (last 4: %s)\n\n' "${image_tag}" "${image_tag: -4}"

    # Check string
    if [[ -n "${check}" ]]; then
      if [[ "${image_tag}" == *"${check}"* ]]; then
        printf '✅ Check string "%s" found in tag\n\n' "${check}"
      else
        printf '⚠️  Check string "%s" NOT found in tag\n' "${check}" >&2
        read -r -p "Continue anyway? (yes/NO): "
        if [[ ! ${REPLY} =~ ^[Yy][Ee][Ss]$ ]]; then
          exit 1
        fi
      fi
    fi

    # Switch context
    kubectl config use-context "${ctx}" || exit 1
    printf 'Context: %s\n\n' "$(kubectl config current-context)"

    # Diff
    local no_changes=false
    if kubectl diff -f "${yaml}"; then
      printf 'No changes — matches cluster state.\n'
      no_changes=true
    else
      local diff_rc=$?
      if ((diff_rc == 1)); then
        printf '\nChanges detected above.\n'
      else
        printf '❌ kubectl diff failed (exit %d)\n' "${diff_rc}" >&2
        exit 1
      fi
    fi
    printf '\n'

    if [[ "${no_changes}" == "true" ]]; then
      printf '✅ Nothing to apply for %s/%s\n' "${app}" "${env}"
      exit 0
    fi

    # Dry run
    kubectl apply --dry-run=server -f "${yaml}" || exit 1
    printf '✅ Dry run passed\n\n'

    # Confirm
    printf '⚠️  PRODUCTION: %s / %s\n' "${app}" "${env}"
    read -r -p "Apply? (yes/NO): "
    if [[ ! ${REPLY} =~ ^[Yy][Ee][Ss]$ ]]; then
      printf 'Cancelled.\n'
      exit 0
    fi

    # Apply
    kubectl apply -f "${yaml}"
    printf '\n'

    # Rollout
    local deploy_name
    deploy_name=$(grep -E '^\s*name:' "${yaml}" | head -1 | awk '{print $2}')
    if [[ -n "${deploy_name}" ]]; then
      kubectl rollout status deployment/"${deploy_name}" --timeout=5m
    else
      printf '⚠️  Could not extract deployment name — check manually\n' >&2
    fi
    printf '\n'

    # Pods
    kubectl get pods -A \
      --field-selector=metadata.namespace!=kube-system \
      --sort-by=.metadata.namespace

    printf '\n✅ Done: %s → %s\n' "${app}" "${env}"
  )
}
