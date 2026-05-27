deploy-attmove-awsweb() {
  cd ~/hrigit/Kubernetes/attmove/awswebprod/ || {
    printf 'Cannot cd to dir\n' >&2
    return 1
  }
  git pull || return 1
  grep 'image:' ./attmove-deploy-awswebprod.yaml
  read -r -p "Apply? (y/N): "
  [[ ${REPLY} =~ ^[Yy]$ ]] || {
    printf 'Cancelled.\n'
    return 0
  }
  kubectl apply --context arn:aws:eks:us-east-1:315633532929:cluster/EksProd -f ./attmove-deploy-awswebprod.yaml
}
deploy-attmoveapi-awsweb() {
  cd ~/hrigit/Kubernetes/attmoveapi/awswebprod/ || {
    printf 'Cannot cd to dir\n' >&2
    return 1
  }
  git pull || return 1
  grep 'image:' ./attmoveapi-deploy-awswebprod.yaml
  read -r -p "Apply? (y/N): "
  [[ ${REPLY} =~ ^[Yy]$ ]] || {
    printf 'Cancelled.\n'
    return 0
  }
  kubectl apply --context arn:aws:eks:us-east-1:315633532929:cluster/EksProd -f ./attmoveapi-deploy-awswebprod.yaml
}
