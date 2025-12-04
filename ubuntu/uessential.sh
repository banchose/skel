#!/usr/bin/env bash

# Essential Packages
sudo apt-get -y update
# sudo apt-get -y install  ldns
sudo apt-get -y install vim
sudo apt-get -y install mtr-tiny
sudo apt-get -y install lshw
sudo apt-get -y install lsof
sudo apt-get -y install socat
sudo apt-get -y install tmux
sudo apt-get -y install ipcalc
sudo apt-get -y install p7zip
sudo apt-get -y install strace
sudo apt-get -y install htop
sudo apt-get -y install rsync
sudo apt-get -y install git
sudo apt-get -y install pv
sudo apt-get -y install w3m
sudo apt-get -y install unzip
sudo apt-get -y install zip
sudo apt-get -y install bc
sudo apt-get -y install curl
sudo apt-get -y install tcpdump
sudo apt-get -y install parted
sudo apt-get -y install iftop
sudo apt-get -y install nmap
sudo apt-get -y install tree
sudo apt-get -y install ufw
sudo apt-get -y install ngrep
# sudo apt-get -y install  openvpn
sudo apt-get -y install dnsutils
sudo apt-get -y install ethtool
sudo apt-get -y install tshark
# sudo apt-get -y install  neofetch
sudo apt-get -y install httping
sudo apt-get -y install pwgen
sudo apt-get -y install dos2unix
sudo apt-get -y install iperf3
# sudo apt-get -y install  words
sudo apt-get -y install silversearcher-ag
sudo apt-get -y install httpie
sudo apt-get -y install dos2unix
sudo apt-get -y install bat
sudo apt-get -y install ripgrep
sudo apt-get -y install fzf
sudo apt-get -y install fd-find
sudo apt-get -y install ripgrep
sudo apt-get -y install python-neovim
sudo apt-get -y install software-properties-common
# For gcc
sudo apt-get -y install build-essential
sudo apt-get -y install gcc
sudo apt-get -y install make
sudo apt-get -y install texlive

# sudo apt-get -y install docker
# sudo apt-get -y install docker-buildx
# sudo apt-get -y install docker-compose

# sudo ufw default deny incoming
# sudo ufw allow SSH
# sudo ufw enable

# sudo apt-get install  hping

# Utilities and extras
sudo apt-get -y install shellcheck
sudo apt-get -y install python3
sudo apt-get -y install python3-pip
# sudo pip install csvkit
sudo apt-get -y install bvi hexedit hexdump
sudo apt-get -y install jq  # JSON
sudo apt-get -y install yq  # yaml
sudo apt-get -y install bat # JSON
sudo mv -v -- /usr/bin/batcat /usr/bin/bat

## Get neovim
curl -L -o ~/nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
chmod u+x nvim.appimage

# sudo apt-get -y install pandoc
# Emacs 28 for doom
##  sudo snap remove emacs
## flatpak uninstall --delete-data org.gnu.emacs
## flatpak uninstall --unused
# sudo apt remove --autoremove emacs emacs-common
# sudo apt install software-properties-common -y
# sudo snap install emacs --classic
# [ ! -d ~/.config/.emacs.d ]] && git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.emacs.d
# # ~/.emacs.d/bin/doom install
# sudo snap install neovim --classic
