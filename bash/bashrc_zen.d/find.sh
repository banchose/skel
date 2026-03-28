# Sourced

alias editfind='nvim ~/gitdir/skel/bash/bashrc_zen.d/find.sh'

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
  find ./ -mount -iname "*$1*" -type f 2>/dev/null
}

flf() {
  find ./ -mount -iname "*$1*" -type f 2>/dev/null
}

find_help() {

  cat <<EOF
-prune - avoid
-exec cmd {} \;
-ok cmd {} \;   # -exec with confirmation
-maxdepth 1
-o or
-a and
-perm u,g,o

+n: for greater than 'n'
-n: for less than 'n'
n: exactly 'n'

-amin
-atime
-cmin
-ctime
-mmin
-mtime

find /tmp -type f,d,l


ind ./ -mount -maxdepth 2 -type f -amin -10 # Less than 10 min

find / -mount -iname "*$1*" -type f 2>/dev/null
find ~/ -daystart -ctime 0
find ~/ -ctime 1 # changed exactly 1 day ago
find ~/ -ctime +1 # find changed more than 48 hours ago
find ~/ -ctime 0  # within the 24 hours
# size
find ./ -size n ('b', 'c', 'w', 'k', 'M', 'G') b is 512, c is bytes
find ./ -size -1M # less than 1M
# Exec
find ./ -name "README*" -exec wc -l {} \;
#
find . \( -name "*.c" -o -name "*.h" \)
find ./ \( -name "*.mp3" -o -iname "*.ra" \) -exec cp {} /mounts/usbhdd/ \;
find . -name "*.txt" -exec echo {} \; -exec grep banana {} \;
# Regardless of success or failure of previous command
find . -name "*.txt" \( -exec echo {} \; -o -exec true \; \) -exec grep banana {} \;
# .git
find . -path ./.git -prune -o -print  # avoid .git
find . -name '.git' -type d
#
#### Simple find using -exec
#
find . -type f -exec file '{}' \;
find ./ -type f ! -name '*.md'
EOF
}
