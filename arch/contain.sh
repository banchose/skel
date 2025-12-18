#!/usr/bin/env bash

set -euo pipefail

mv /etc/pacman.d/mirrorlist{,.orig}

echo 'Server = http://archmirror.example.net/archlinux/$repo/os/$arch cat > /etc/pacman.d/mirrorlist' > /etc/pacman.d/mirrorlist

useradd -m -g users -G wheel -s /bin/bash una
sed -i.orig."$RANDOM" 's/# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

useradd -m -g users -G wheel -s /bin/bash una
passwd una test

passwd root test

pacman -Suy
pacman -S neovim vim vi bat
