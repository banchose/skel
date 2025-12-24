xpy0() {

  mount=
  [[ -d ~/gitdir/skel ]] && mount="-v $HOME/gitdir/skel:/home/loon/gitdir/skel:ro ${mount}"
  [[ -d ~/temp ]] && mount="-v $HOME/temp:/home/loon/temp:ro ${mount}"
  echo "${mount}"

  docker run -it --rm --name py0 --hostname py0 ${mount} py0:latest

}
