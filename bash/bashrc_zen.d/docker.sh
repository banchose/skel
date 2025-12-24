# Don't source if not a hint of Docker
if type docker &>/dev/null; then
  # export UID=$(id -u)
  # export GID=$(id -g)

  export BUILDKIT_PROGRESS=plain

  alias rdp='docker -H ssh://una@s1 ps --all'
  alias rdr='docker -H ssh://una@s1 ps'
  alias rde='docker -H ssh://una@s1'
  alias rdx='docker -H ssh://una@s1 container prune'

  # alias d='docker'
  alias dpls='docker ps --format "table {{.Image}}\t{{.Names}}\t{{.Status}}"'
  alias dp='docker ps'
  alias dl='docker ps -l'
  alias di='docker images'
  alias dlc='docker container ls'
  alias dlspa='docker ps --all'
  alias dps='docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.RunningFor}}"'
  alias dpsp='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
  alias alpine0='docker run -it --rm --name alpine0 --hostname alpine0 -v ~/temp:/home/loon/temp alpine0:latest'
  alias trixie0='docker run -it --rm --name trixie0 --hostname trixie0 -v ~/temp:/home/loon/temp trixie0:latest'
  alias trixie0r='docker run -u root -it --rm --name trixie0 --hostname trixie0 -v ~/temp:/home/loon/temp trixie0:latest'
  alias trixie0bld='docker build -t trixie0:latest --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" .'

  # py0
  # alias py0='docker run -it --rm --name py0 --hostname py0 -v ~/temp:/home/loon/temp py0:latest'
  alias py0r='docker run --name py0 -u root -it --rm --hostname py0 -v ~/temp:/home/loon/temp py0:latest'
  alias py0b='cd ~/gitdir/skel/docker/builds/py0 && docker build -t py0:latest --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" .'
  # functin

  # py1
  alias py1='docker run -it --rm --name py1 --hostname py1 -v ~/temp:/home/loon/temp py1:latest'
  alias py1r='docker run --name py1 -u root -it --rm --hostname py1 -v ~/temp:/home/loon/temp py1:latest'
  # alias py1b='cd ~/gitdir/skel/docker/builds/py1 && docker build -t py1:latest --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" .'
  alias py1b='cd ~/gitdir/skel/docker/builds/py1 && docker build -t py1:latest .'

  py0() {
    local mount_args=()

    [[ -d ~/gitdir/skel ]] && mount_args+=(-v "$HOME/gitdir/skel:/home/loon/gitdir/skel")
    [[ -d ~/temp ]] && mount_args+=(-v "$HOME/temp:/home/loon/temp:ro")

    docker run -it --rm --name py0 --hostname py0 "${mount_args[@]}" py0:latest
  }

  function dconnet() {

    docker ps --format '{{.Names}}' | while read -r container; do
      networks=$(docker inspect $container --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}')
      echo "$container: $networks"
    done | column -t -s ':'

  }

  function dpip() {

    docker ps --format '{{.Names}}' | while read -r container; do
      networks=$(docker inspect $container --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}:{{.IPAddress}} {{end}}')
      printf "%-40s %s\n" "$container" "$networks"
    done

  }
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

  function getshell() {

    docker run -it --rm -v ~/.aws:/root/.aws:ro -v ~/.bashrc:/root/.bashrc:ro -v ~/.inputrc:/root/.inputrc:ro -v ~/.bashrc_zen.d:/root/.bashrc_zen.d:ro -v ~/gitdir/skel:/root/gitdir/skel:ro -v ~/gitdir:/root/gitdir:ro --entrypoint /bin/bash amazon/aws-cli
  }
# [[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://orb.example.net"
# [[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://star.example.net"
fi
