#!/bin/bash

# Notes
#  $ grep -i qxl ~/.local/share/xorg/Xorg.0.log
# or
# $ sudo lshw -c Video
#  $ xrandr --verbose
#  $ xrandr --verbose | grep -i connected
# Can copy packages from elsewhere to /var/cache/pacman/pkg
# dmesg --color=always | less -R
#
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si

# In 10/2019 the base group was replaced by a base package.
# This package is bare-bones and doesn't include a kernel
# or linux-firmware, intel-ucode, man pages or an editor and
# other "expected" packages
# Min: pacstrap /mnt base linux linux-firmware vi vim
# Better: pacstrap /mnt base linux linux-firmware intel-ucode man-db \
# vim lvm2 cryptsetup man-db man-pages less diffutils texinfo

sudo timedatectl set-ntp true

# Essential Packages

sudo pacman -S base --needed -noconfirm
sudo pacman -S base-devel --needed -noconfirm
sudo pacman -S openssh --needed --noconfirm
sudo pacman -S iputils --needed --noconfirm # has ping
sudo pacman -S iproute2 --needed --noconfirm
sudo pacman -S lvm2 --needed --noconfirm
sudo pacman -S nvme-cli --needed --noconfirm
sudo pacman -S man --needed --noconfirm
sudo pacman -S man-db --needed --noconfirm
sudo pacman -S binutils --needed --noconfirm
sudo pacman -S man-pages --needed --noconfirm
sudo pacman -S texinfo --needed --noconfirm
sudo pacman -S usbutils --needed --noconfirm
sudo pacman -S less --needed --noconfirm
sudo pacman -S dmidecode --needed --noconfirm
sudo pacman -S vim --needed --noconfirm
sudo pacman -S vi --needed --noconfirm
sudo pacman -S bash-completion --needed --noconfirm
sudo pacman -S nano --needed --noconfirm
sudo pacman -S lshw --needed --noconfirm
sudo pacman -S lsof --needed --noconfirm
sudo pacman -S socat --needed --noconfirm
sudo pacman -S tmux --needed --noconfirm
sudo pacman -S ipcalc --needed --noconfirm
sudo pacman -S perf --needed --noconfirm
sudo pacman -S p7zip --needed --noconfirm
sudo pacman -S strace --needed --noconfirm
sudo pacman -S htop --needed --noconfirm
sudo pacman -S mtr --needed --noconfirm
sudo pacman -S dosfstools --needed --noconfirm
sudo pacman -S git --needed --noconfirm
sudo pacman -S pv --needed --noconfirm
sudo pacman -S w3m --needed --noconfirm
sudo pacman -S unzip --needed --noconfirm
sudo pacman -S zip --needed --noconfirm
sudo pacman -S bc --needed --noconfirm
sudo pacman -S pcre2 --needed --noconfirm
sudo pacman -S openbsd-netcat --needed --noconfirm
sudo pacman -S gdb --needed --noconfirm
sudo pacman -S nasm --needed --noconfirm
sudo pacman -S tcpdump --needed --noconfirm
sudo pacman -S parted --needed --noconfirm
sudo pacman -S iftop --needed --noconfirm
sudo pacman -S nmap --needed --noconfirm
sudo pacman -S tree --needed --noconfirm
sudo pacman -S ufw --needed --noconfirm
sudo pacman -S ngrep --needed --noconfirm
sudo pacman -S openvpn --needed --noconfirm
sudo pacman -S iostat --needed --noconfirm
sudo pacman -S bind-tools --needed --noconfirm
sudo pacman -S ethtool --needed --noconfirm
sudo pacman -S wol --needed --noconfirm
sudo pacman -S wireshark-cli --needed --noconfirm
sudo pacman -S pwgen --needed --noconfirm
sudo pacman -S nethogs --needed --noconfirm
sudo pacman -S httping --needed --noconfirm
sudo pacman -S lsscsi --needed --noconfirm
sudo pacman -S hdparm --needed --noconfirm
sudo pacman -S minicom --needed --noconfirm
sudo pacman -S pigz --needed --noconfirm
sudo pacman -S wireguard-tools --needed --noconfirm
sudo pacman -S iw --needed --noconfirm
sudo pacman -S iwd --needed --noconfirm
# sudo pacman -S ntfs-3g --needed --noconfirm
sudo pacman -S mlocate --needed --noconfirm
sudo pacman -S iperf3 --needed --noconfirm
sudo pacman -S sysstat --needed --noconfirm # iostat, mpstat,pidstat,sar,...
sudo pacman -S iotop --needed --noconfirm
sudo pacman -S ncftp --needed --noconfirm
sudo pacman -S httpie --needed --noconfirm
sudo pacman -S dos2unix --needed --noconfirm
sudo pacman -S python-pynvim --needed --noconfirm
# New arch are missing these
sudo pacman -S gcc --needed --noconfirm
sudo pacman -S binutils --needed --noconfirm
sudo pacman -S ltrace --needed --noconfirm
sudo pacman -S make --needed --noconfirm
sudo pacman -S cmake --needed --noconfirm
sudo pacman -S linux-firmware --needed --noconfirm
sudo pacman -S intel-ucode --needed --noconfirm
sudo pacman -S efibootmgr --needed --noconfirm
sudo pacman -S edk2-shell --needed --noconfirm
sudo pacman -S edk2-ovmf --needed --noconfirm
sudo pacman -S hexyl --needed --noconfirm
sudo pacman -S inetutils --needed --noconfirm
# gcc make which fakeroot and needed for makepkg
sudo pacman -S go --needed --noconfirm
sudo pacman -S exfat-utils --needed --noconfirm
sudo pacman -S libsecret --needed --noconfirm
sudo pacman -S rsync --needed --noconfirm
sudo pacman -S rclone --needed --noconfirm
# Find damn you
sudo pacman -S the_silver_searcher --needed --noconfirm
sudo pacman -S fd --needed --noconfirm
sudo pacman -S ripgrep --needed --noconfirm
# X.509 tool
sudo pacman -S step-cli --needed --noconfirm
# Download utility
sudo pacman -S wget --needed --noconfirm
sudo pacman -S aria2 --needed --noconfirm
sudo pacman -S curl --needed --noconfirm
sudo pacman -S arch-wiki-lite --needed --noconfirm
sudo pacman -S arch-wiki-docs --needed --noconfirm
# Experimental
sudo pacman -S tidy --needed --noconfirm
sudo pacman -S httrack --needed --noconfirm
sudo pacman -S lm_sensors --needed --noconfirm
sudo pacman -S reflector --needed --noconfirm

sudo pacman -S udiskie --needed --noconfirm
sudo pacman -S rust --needed --noconfirm
sudo pacman -S neovim --needed --noconfirm
sudo pacman -S tree-sitter-cli --needed --noconfirm
sudo pacman -S python-pynvim --needed --noconfirm

# Arch Linux hrd cor
if grep -q 'archlinux' /proc/version; then
	sudo pacman -S arch-wiki-lite --needed --noconfirm
	sudo pacman -S arch-wiki-docs --needed --noconfirm
fi

# yay
# sudo pacman -S base-devel --needed --noconfirm # req for makepkg
# cd ~/temp;git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si

# Pipewire
# sudo pacman wireplumber --needed
## sudo pacman -S pipewire-alsa --needed
# sudo pacman -S pipewire-pulse --needed

# BCC - drags in LLVM
# pacman -S linux-headers --needed
# yay -S bcc --needed       # /usr/share/bcc/{examples,introspection}
# yay -S bcc-tools --needed # /usr/share/bcc/{tools,man}
# yay -S python-bcc --needed
# yay -S bpftrace --needed

# Spelling

sudo pacman -S hunspell --needed --noconfirm
sudo pacman -S hunspell-en_US --needed --noconfirm

# Wireless
# sudo pacman -S dialog --needed --noconfirm
# sudo pacman -S wifi-menu --needed --noconfirm
# sudo pacman -S wpa_supplicant --needed --noconfirm

# Extra no X
sudo pacman hexyl --needed --noconfirm
sudo pacman -S bat --needed --noconfirm
sudo pacman -S ranger --needed --noconfirm
# sudo pacman -S yt-dlp --needed --noconfirm

# Very extra no X
sudo pacman -S words --needed --noconfirm
# sudo pacman -S neofetch  --needed --noconfirm
# sudo pacman -S firejail --needed --noconfirm
# sudo pacman -S ldns    --needed --noconfirm
#
# Arch Linux but where else would I be running it?
if grep -q 'archlinux' /proc/version; then
	sudo pacman -S arch-wiki-lite --needed --noconfirm
	sudo pacman -S reflector --needed --noconfirm
fi
#
# if (sudo dmidecode | grep -iq "Manufacturer: QEMU"); then
#   sudo pacman -S qemu-guest-agent --needed --noconfirm
#   sudo pacman -S spice-vdagent --needed --noconfirm
#   # gpg --recv-keys --keyserver hkp://pgp.mit.edu A9D8C21429AC6C82
#   sudo pacman -S xf86-video-qxl --needed --noconfirm
#   sudo systemctl --now enable qemu-ga
#   sudo systemctl --now enable spice-vdagentd
#   # # # xrandr --output Virtual-0 --mode 1920x1080
# fi

##############################################
# Graphical
##############################################
# Wayland
# sudo pacman -S wl-clipboard --needed
# sudo pacman -S alacritty --needed
# sudo pacman -S waybar --needed
# sudo pacman -S imv --needed # wayland image viewer
## HW Accel
# sudo pacman -S libva-mesa-driver --needed
# sudo pacman -S libva-utils  --needed

# Applications
# sudo pacman -S zathura --needed # super cust pdf,epub reader
# sudo pacman -S zathura-pdf-mupdf --needed

# Fonts

# sudo pacman -S noto-fonts --needed
# sudo pacman -S ttf-dejavu  --needed
# sudo pacman -S ttf-liberation --needed
# sudo pacman -S noto-fonts-cjk  --needed
# sudo pacman -S ttf-nerd-fonts-symbols  --needed
