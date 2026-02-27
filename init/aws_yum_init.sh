#!/usr/bin/env bash

set -xeuo pipefail

sudo localectl set-locale LANG=en_US.UTF-8
sudo timedatectl set-timezone America/New_York
sudo hostnamectl set-hostname "aws-prd-tomcat-1"
sudo yum install -y wireshark-cli
sudo yum install -y tmux
sudo yum install -y mtr
sudo yum install -y jq
sudo yum install -y cowsay
sudo yum install -y git
sudo yum install -y python3
sudo yum install -y python3-pip
sudo yum install -y golang
sudo yum install -y cargo
sudo yum install -y gettext
sudo yum install -y ninja-build
sudo yum install -y cmake
sudo yum install -y gcc
sudo yum install -y unzip
sudo yum install -y gettext
sudo yum install -y make
sudo yum install -y nmap
sudo yum install -y unzip --allowerasing
sudo yum install -y gettext
sudo yum install -y curl --allowerasing
sudo yum install -y cargo
sudo yum install -y rust
sudo yum install -y rust-doc
sudo yum install -y nmap
sudo yum install -y p7zip
sudo yum install -y p7zip-plugins
sudo yum install -y p7zip-doc
sudo yum install -y socat
sudo yum install -y ncurses
sudo yum install -y golang
