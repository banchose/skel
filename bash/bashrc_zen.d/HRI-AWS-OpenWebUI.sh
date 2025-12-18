webuilogs() {

  if aws sts get-caller-identity --region us-east-1 --profile test; then
    kubectl logs -n openwebui statefulsets/open-webui --context arn:aws:eks:us-east-1:405350004483:cluster/EksTest
  fi

}
