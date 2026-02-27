#!/usr/bin/env bash

set -xeuo pipefail

localectl set-locale LANG=en_US.UTF-8
timedatectl set-timezone America/New_York
hostnamectl set-hostname "aws-prd-tomcat-1"
yum install -y wireshark-cli
yum install -y tmux
yum install -y mtr
yum install -y jq
yum install -y cowsay
yum install -y git
yum install -y python3
yum install -y python3-pip
yum install -y golang
yum install -y cargo
yum install -y gettext
yum install -y ninja-build
yum install -y cmake
yum install -y gcc
yum install -y unzip
yum install -y gettext
yum install -y make
yum install -y nmap
yum install -y unzip --allowerasing
yum install -y gettext
yum install -y curl --allowerasing
yum install -y cargo
yum install -y rust
yum install -y rust-doc
yum install -y nmap
yum install -y p7zip
yum install -y p7zip-plugins
yum install -y p7zip-doc
yum install -y socat
yum install -y ncurses
yum install -y golang
