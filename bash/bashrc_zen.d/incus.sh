alias lxc='echo "Use incus"'

# incus launch images:archlinux archvm --vm -c limits.memory=16GiB -c security.secureboot=false -c limits.cpu=4
#
#  incus profile create archvm                                                                                                         │
#  incus profile set archvm limits.memory=16GiB security.secureboot=false                                                              │
#  incus launch images:archlinux archvm2 --vm -p default -p archvm
#
