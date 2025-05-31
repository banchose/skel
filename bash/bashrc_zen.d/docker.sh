# Don't source if not a hint of Docker
if type docker &>/dev/null; then
  # export UID=$(id -u)
  # export GID=$(id -g)

  alias rdp='docker -H ssh://una@s1 ps --all'
  alias rdr='docker -H ssh://una@s1 ps'
  alias rde='docker -H ssh://una@s1'
  alias rdx='docker -H ssh://una@s1 container prune'

  # alias d='docker'
  alias dlsb='docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Status}}"'
  alias dp='docker ps'
  alias dl='docker ps -l'
  alias di='docker images'
  alias dlc='docker container ls'
  alias dlspa='docker ps --all'

  function dkill() {

    for i in $(docker ps -q); do
      docker kill "${i}"
    done

  }

  function dclear() {
    cons="$(docker ps -q)"
    [[ -z $cons ]] || docker stop $cons
    dkill # defined here
    docker container prune -f
    docker volume prune -f
  }

  function dboom() {

    dclear # defined here
    docker system prune -af
    docker volume prune -fa
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
