#!/usr/bin/env bash

set -euo pipefail

cd ~/temp || {
  echo "$HOME/temp does not exist"
  exit 1
}

img=Arch-Linux-x86_64-cloudimg
[[ -f ${img} ]] || curl -LO https://geo.mirror.pkgbuild.com/images/latest/"${img}"
gpg --verify Arch-Linux-x86_64-cloudimg.qcow2.sig Arch-Linux-x86_64-cloudimg.qcow2

qemu-img create -f qcow2 -F qcow2 -b "${img}" arch-vm.qcow2 20G
