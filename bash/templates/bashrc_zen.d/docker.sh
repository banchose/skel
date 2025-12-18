# Don't source if not a hint of Docker
type docker &>/dev/null || return 0

alias rdp='docker -H ssh://una@s1 ps --all'
alias rdr='docker -H ssh://una@s1 ps'
alias rde='docker -H ssh://una@s1'
alias rdx='docker -H ssh://una@s1 container prune'

alias d='docker'
alias dls='docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Status}}"'
source <(docker completion bash)
complete -F __start_docker d

function dwipe() {
	docker container prune --force
	docker image prune --force --all
}

function dockerpurge() {

	docker rm -f $(docker ps -aq)
	docker system prune -f -a # Boom
	docker volume prune -f
	docker network prune -f

}

function dockupdate() {

	for i in $(docker images | tail -n +2 | awk '{ print $1 }'); do docker pull "$i"; done
}

# [[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://orb.example.net"
[[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://star.example.net"
