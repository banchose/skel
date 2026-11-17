#!/usr/bin/env bash

set -euo pipefail

cd ~/temp || {
  echo "$HOME/temp does not exist"
  exit 1
}

import_keys() {

  import_keys() {
    local FPR=1B9A16984A4E8CB448712D2AE0B78BF4326C6F8F

    if gpg --list-keys "$FPR" >/dev/null 2>&1; then
      echo "arch-boxes key already imported"
      return 0
    fi

    gpg --keyserver hkps://keyserver.ubuntu.com --recv-keys "$FPR" ||
      {
        echo "couldn't fetch key $FPR from keyserver" >&2
        return 1
      }

    gpg --list-keys "$FPR" >/dev/null 2>&1 ||
      {
        echo "key $FPR still not in keyring after fetch" >&2
        return 1
      }
  }
}

img=Arch-Linux-x86_64-cloudimg.qcow2
[[ -f ${img} ]] || {
  curl -LO https://geo.mirror.pkgbuild.com/images/latest/"${img}"
  curl -LO https://geo.mirror.pkgbuild.com/images/latest/"${img}".sig
}
gpg --verify Arch-Linux-x86_64-cloudimg.qcow2.sig Arch-Linux-x86_64-cloudimg.qcow2

qemu-img create -f qcow2 -F qcow2 -b "${img}" arch-vm.qcow2 20G
