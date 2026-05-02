# Don't source if not a hint of Docker
if type docker &>/dev/null; then
  # export UID=$(id -u)
  # export GID=$(id -g)

  export BUILDKIT_PROGRESS=plain
  export DOCKER_BUILDKIT=1

  alias editdocker='nvim ~/gitdir/skel/bash/bashrc_zen.d/docker.sh'
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

  # py1
  alias py1='docker run -it --rm --name py1 --hostname py1 -v ~/temp:/home/loon/temp py1:latest'
  alias py1r='docker run --name py1 -u root -it --rm --hostname py1 -v ~/temp:/home/loon/temp py1:latest'
  # alias py1b='cd ~/gitdir/skel/docker/builds/py1 && docker build -t py1:latest --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" .'
  alias py1b='cd ~/gitdir/skel/docker/builds/py1 && docker buildx build -t py1:latest .'

  # py0 ######################

  # alias py0='docker run -it --rm --name py0 --hostname py0 -v ~/temp:/home/loon/temp py0:latest'

  alias cdpy0='cd -- ~/gitdir/skel/docker/builds/py0'
  alias py0r='docker run --name py0 -u root -it --rm --hostname py0 -v ~/temp:/home/loon/temp2 py0:latest'
  # alias py0b='cd ~/gitdir/skel/docker/builds/py0 && docker buildx build -t py0:latest --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" .'
  alias py0t='docker run --name py0  -it --rm --hostname py0 -v ~/temp:/home/loon/temp2 py0:latest tmux'

  py0b() {
    (
      cd ~/gitdir/skel/docker/builds/py0 || exit 1

      command cp -L -v -- ~/.config/io.datasette.llm/templates/*.yaml LLM/templates/

      docker buildx build -t py0:latest \
        --build-arg USER_UID="$(id -u)" \
        --build-arg USER_GID="$(id -g)" \
        .
    )
  }

  py0() {
    local mount_args=()

    #   [[ -d ~/gitdir/skel ]] && mount_args+=(-v "$HOME/gitdir/skel:/home/loon/gitdir/skel")
    [[ -d ~/temp ]] && mount_args+=(-v "$HOME/temp:/home/loon/temp2:ro")
    [[ -d ~/gitdir ]] && mount_args+=(-v "$HOME/gitdir:/home/loon/gitdir:ro")

    docker run -it --rm --name py0 --hostname py0 "${mount_args[@]}" py0:latest
  }

  function dconnet() {

    docker ps --format '{{.Names}}' | while read -r container; do
      networks=$(docker inspect "${container}" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}} {{end}}')
      echo "$container: $networks"
    done | column -t -s ':'

  }

  function dpip() {

    docker ps --format '{{.Names}}' | while read -r container; do
      networks=$(docker inspect "${container}" --format '{{range $k, $v := .NetworkSettings.Networks}}{{$k}}:{{.IPAddress}} {{end}}')
      printf "%-40s %s\n" "$container" "$networks"
    done

  }
  function dkill() {

    for i in $(docker ps -q); do
      docker kill "${i}"
    done

  }

  function dclear() {
    local -a cons
    readarray -t cons < <(docker ps -q)
    ((${#cons[@]})) && docker stop "${cons[@]}"
    dkill
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
    local -a contains
    readarray -t contains < <(docker ps -aq)
    ((${#contains[@]})) && docker rm -f "${contains[@]}"
    docker system prune -f -a
    docker volume prune -f
    docker network prune -f
  }

  function dockupdate() {

    for i in $(docker images | tail -n +2 | awk '{ print $1 }'); do docker pull "$i"; done
  }

  function getshell() {

    docker run -it --rm -v ~/.aws:/root/.aws:ro -v ~/.bashrc:/root/.bashrc:ro -v ~/.inputrc:/root/.inputrc:ro -v ~/.bashrc_zen.d:/root/.bashrc_zen.d:ro -v ~/gitdir/skel:/root/gitdir/skel:ro -v ~/gitdir:/root/gitdir:ro --entrypoint /bin/bash amazon/aws-cli
  }

  function docker_help() {

    cat <<EOF
### ENTRYPOINT
ENTRYPOINT will always execute unless --entrypoint
ENTRYPOINT ["bash", "/somescript" ]
### Simple Dockerfile
FROM ubuntu:latest
RUN apt-get update
RUN apt-get install -y build-essential
WORKDIR /app
COPY app/hello.c /app/
RUN gcc -o hello hello.c
ENTRYPOINT [ "/app/hello" ]
###
### REGISTRY
docker run --name register -d -p 1180:5000 registry 
##
docker run -it --rm --user ubuntu ubuntu
## service dns names
# if not on the default bridge
docker inspect $(docker ps -q) --format '{{.Name}}: {{range .NetworkSettings.Networks}}{{.DNSNames}} {{end}}'
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
docker run -it -d -p 8000:8000 --rm bash -- nc -kl -p 8000
docker --dns 8.8.8.8 --dns 1.1.1.1
docker --dns-search example.net
docker --hostname # containers hostname
docker create --cap-drop ALL --cap-add NET_ADMIN -p 8080:8080 -ti --name bashY bash
docker commit <containerName> my_image_yay
docker run -it --rm --network mynet ubuntu bash -c "timeout 1 bash -c ': < /dev/tcp/registry/5000'"
--- simple server
docker run --rm -p 9005:9005 --name busybox  busybox nc -lkp 9005 -e sh -c 'printf "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n"'
OR
docker run --rm -p 9005:9005 --name busybox1 busybox sh -c '
  echo -e "#!/bin/sh\nprintf \"HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n\"\nls" > /tmp/serve.sh
  chmod +x /tmp/serve.sh
  nc -lkp 9005 -e /tmp/serve.sh
'
--- docker compose
services:
  mock-service:
    image: nicolaka/netshoot # or any image with nc installed
    container_name: mock-service
    command:
      - sh
      - -c
      - |
          printf '#!/bin/sh\nprintf "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n"\nls\n' > /tmp/serve.sh
          chmod +x /tmp/serve.sh
          nc -lkp 8080 -e /tmp/serve.sh
    ports:
      - "8080:8080"
    networks:
      - red-net
      - blue-net
      - orange-net
---
EOF
  }

# [[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://orb.example.net"
# [[ $HOSTNAME == arc ]] && export DOCKER_HOST="ssh://star.example.net"
fi
