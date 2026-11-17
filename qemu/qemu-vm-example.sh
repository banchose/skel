#!/usr/bin/env bash

set -euo pipefail

cd ~/temp || {
  echo "$HOME/temp does not exist"
  exit 1
}

import_keys() {

  local FPR=1B9A16984A4E8CB448712D2AE0B78BF4326C6F8F

  if gpg --list-keys "$FPR" >/dev/null 2>&1; then
    echo "arch-boxes key already imported"
  else
    curl -sfL https://gitlab.archlinux.org/archlinux/arch-boxes/-/raw/master/README.md |
      sed -n '/BEGIN PGP/,/END PGP/p' >arch-boxes.asc
    got=$(gpg --show-keys --with-colons arch-boxes.asc | awk -F: '/^fpr:/ {print $10; exit}')
    if [[ "$got" != "$FPR" ]]; then
      echo "fingerprint mismatch: got '$got', expected $FPR; not importing" >&2
      exit 1
    fi
    gpg --import arch-boxes.asc
  fi
}

img=Arch-Linux-x86_64-cloudimg.qcow2
[[ -f ${img} ]] || {
  curl -LO https://geo.mirror.pkgbuild.com/images/latest/"${img}"
  curl -LO https://geo.mirror.pkgbuild.com/images/latest/"${img}".sig
}
gpg --verify Arch-Linux-x86_64-cloudimg.qcow2.sig Arch-Linux-x86_64-cloudimg.qcow2

qemu-img create -f qcow2 -F qcow2 -b "${img}" arch-vm.qcow2 20G
