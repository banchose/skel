# Don't source if not a hint of Docker
if type docker &>/dev/null; then
  # export UID=$(id -u)
  # export GID=$(id -g)

  alias rdp='docker -H ssh://una@s1 ps --all'
  alias rdr='docker -H ssh://una@s1 ps'
  alias rde='docker -H ssh://una@s1'
  alias rdx='docker -H ssh://una@s1 container prune'
  alias dboom='docker system prune -af;docker volume prune -fa;docker container prune -f'

  alias d='docker'
  alias dls='docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Status}}"'
  # source <(docker completion bash)
  # complete -F __start_docker d
  alias dkill='for i in $(docker ps -q);do docker kill "${i}";done'

  dls() {

    docker ps --format 'table {{.ID}}\t{{.Names}}'

  }

  dclear() {
    cons="$(docker ps -q)"
    [[ -z $cons ]] || docker stop $cons
    docker container prune -f
  }

  function dwipe() {
    docker container prune --force
    docker image prune --force --all
  }

  function dockerpurge() {

    contains=$(docker ps -aq)
    [[ -z $contains ]] || docker rm -f $contains
    docker system prune -f -a # Boom
    docker volume prune -f
    docker network prune -f

  }

  function dockupdate() {

    for i in $(docker images | tail -n +2 | awk '{ print $1 }'); do docker pull "$i"; done
  }

# [[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://orb.example.net"
# [[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://star.example.net"
fi
