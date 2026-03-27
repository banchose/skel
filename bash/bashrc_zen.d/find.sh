# Sourced

function xfg() {

  [[ -z $1 ]] && {
    echo "Missing search parameter"
    return 1
  }

  find . -path './gitdir' -prune -o -name "*${1}*" -print

}

function xfinddsk() {

  find /sys/devices -type f -name model -exec cat {} \;

}

ff() {
  find / -mount -iname "*$1*" -type f 2>/dev/null
}

flf() {
  find ./ -mount -iname "*$1*" -type f 2>/dev/null
}
