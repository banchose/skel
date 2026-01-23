# Sourced as a bash init script

# Avoid if no hint of Kubernetes
type kubectl &>/dev/null || return 0

export kport=43549

alias k='kubectl'
alias ka='kubectl get all -A'
alias kpa='kubectl get pods -A'
alias kpp='kubectl get pods'
alias kp='kubectl get pods -A --field-selector=metadata.namespace!=kube-system --sort-by=.metadata.namespace'
alias kpw='kubectl get pods -o wide'
alias kpaw='kubectl get pods -A -o wide'
alias kn='kubectl get nodes'
alias knw='kubectl get nodes -o wide'
alias kna='kubectl get nodes -A'
alias knaw='kubectl get nodes -A -o wide'
alias kd='kubectl get deployment'
alias kdw='kubectl get deployment -o wide'
alias kda='kubectl get deployment -A'
alias kdaw='kubectl get deployment -A -o wide'
alias ks='kubectl get svc -A'
alias kc='kubectl config current-context'
# alias kct='kubectl config use-context Test'
alias kn='kubectl get nodes'
alias ki='kubectl get ingress -A'
alias kra='for i in $(kubectl api-resources -o name);do echo "${i%%.*}";kubectl get "${i%%.*}";done'
alias klsp='kubectl run  -it alpine-test --image=alpine --restart=Never --rm --command  -- ls'
alias akcurl='kubectl run -it curl-$RANDOM --rm --restart=Never --image=curlimages/curl --'

kwhoami() {

  kubectl auth can-i --list
  kubectl config current-context

}

kbash() {

  if kubectl get pods | grep kbash; then
    kubectl exec -it kbash -- bash
  else
    kubectl run -it --tty --restart=Always --image=bash:latest kbash
  fi
}

kxbt() {

  kubectl run -it bash-count --rm --restart=Never --image=bash:latest -- -c 'for i in {1..10};do echo "$i";done'
}

kxbs() {

  kubectl run -it bash-kbp --rm --restart=Never --image=bash:latest
}

kxct() {

  kubectl run -it curl-1 --rm --restart=Never --image=curlimages/curl --command -- curl --version
  kubectl run -it curl-1 --rm --restart=Never --image=curlimages/curl -- --version
}

kcurl() {

  kubectl run -it curl-1 --rm --restart=Never --image=curlimages/curl -- --max-time 10 --connect-timeout 5 "$@"
}

source <(kubectl completion bash)
# complete -F __start_kubectl k

getyn() {
  local yn='n'
  while true; do
    read -n 1 -p "Do you want to continue? (y/n): " yn
    case $yn in
    [Yy]*)
      exec some_command_here
      break
      ;;
    [Nn]*) exit ;;
    *) echo "Please answer y or n." ;;
    esac
  done
}

klc() {
  kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |
    sort
}

mkbashC() {
  kubectl run -i --tty --image=bash --restart=Always xbx -- bash
}

mkkubeconfg() {

  [[ -r /etc/kubernets/admin.conf ]] || {
    echo "No /etc/kubernetes/admin.conf file"
    return 1
  }
  [[ -d ~/.kube ]] || mkdir -p -- ~/.kube
  sudo cp -v /etc/kubernetes/admin.conf ~/.kube
  sudo chown -R -- "$USER":users ~/.kube
}

mkkube() {
  [[ -d ~/.kube ]] || mkdir -p -- ~/.kube &>/dev/null
  sudo cp -v -- /etc/kubernetes/admin.conf "$SUDO_USER/.kube"
  sudo chown -v -R -- "$SUDO_USER":users "$SUDO_USER/.kube"
}

kscale() {
  kubectl scale -n nginx-a --replicas 1 deployment nginx-a
}

kpodr() {
  kubectl get pods --sort-by='.status.containerStatuses[0].restartCount'
}

ketca() {
  kubectl config view --raw | awk '/certificate-authority-data:/ { print $2 }' | base64 -d | openssl x509 -text -noout
}
ketcca() {
  kubectl config view --raw | awk '/client-certificate-data:/ { print $2 }' | base64 -d | openssl x509 -text -noout
}

kscan() {
  for i in $(kubectl config get-contexts --no-headers=true -o name); do
    echo "$i"
    kubectl config use-context "$i"
    kubectl get pods
  done
}
