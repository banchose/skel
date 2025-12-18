# Sourced as a bash init script

# Avoid if no hint of Kubernetes
type kubectl &>/dev/null || return 0

export kport=43549

alias k='kubectl'
alias ka='kubectl get all -A'
alias kp='kubectl get pods'
alias kpw='kubectl get pods -o wide'
alias kpa='kubectl get pods -A'
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
alias kcp='kubectl config use-context Production'
alias kct='kubectl config use-context Test'
alias kn='kubectl get nodes'
alias kp='kubectl get pods'

source <(kubectl completion bash)
complete -F __start_kubectl k

[[ -d $HOME/.krew/bin ]] && export PATH="$PATH:$HOME/.krew/bin"

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
