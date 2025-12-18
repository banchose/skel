FROM debian:trixie

#
# docker build -t py1:latest --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" .

# Example user
# RUN useradd -rm -d /home/ubuntu -s /bin/bash -g root -G sudo -u 1001 ubuntu
# -p "$(openssl passwd -6 YOUR_PASS_HERE)"
#
# OR
#
# SHELL ["/bin/bash", "-o", "pipefail", "-c"]
# RUN echo 'ubuntu:ubuntu' | chpasswd
#
# USER ubuntu
# WORKDIR /home/ubuntu

### ROOT ###

USER root
WORKDIR /root

RUN apt update && apt install -y \
  bash \
  bash-completion  \
  zsh  \
  git \
  curl \
  iproute2 \
  iputils-ping \
  traceroute \
  iperf3 \
  telnet \
  jq \
  net-tools \
  dnsutils \
  sed \
  grep \
  gawk \
  coreutils \
  diffutils \
  lsof \
  vim  \
  zip \
  bzip2 \
  xz-utils \
  inxi \
  gettext \
  manpages \
  man-db \
  fzf \
  unzip \
  p7zip-full \
  ipcalc  \
  tshark \
  strace \
  nmap \
  mtr  \
  wget  \
  tcpdump \
  socat \
  htop  \
  tmux \
  netcat-openbsd \
  tree \
  bat \
  vim  \
  ripgrep \
  btrfs-progs \
  apt-utils \
  fd-find \
  shellcheck \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

RUN apt update && apt install -y \
 # samurai  \
  libtool \
  ninja-build \
  meson \
  autoconf \
  automake \
  doxygen \
  yasm \
  make \
  cmake \
  gfortran \
  rclone \
  gcc \
  g++ \
  gdb \
  pigz \
  nasm \
  luajit \
  lua5.1-doc \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# As root
RUN apt update && apt install -y \
  python3.13-venv \
  pip \
  faker \
  python3-pynvim \
  ipython3 \
  python3-ipython \
  ptpython \
  pylint \
  python3-networkx \
  python3-httpx \
  python3-requests \
  python3-boto3 \
  python3-arrow  \
  python3-cryptography \
  python3-loguru \
  python3-icecream \
  python3-scipy \
  python3-simpy \
  python3-numpy \
  python3-purl \
  python3-certifi \
  python3-pydantic \
  python3-twisted \
  twisted-doc \
  python3-jinja2 \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean 


RUN apt update && apt install -y \
  units \
  pandoc \
  pwgen \
  aria2 \
  s3cmd \
  texlive \
  texinfo \
  hping3 \
  ngrep \
  asciinema \
  # exa \
  duf \
  # tldr \
  dsniff \
  qalc \
  bc \
  iftop \
  silversearcher-ag \
  openvpn \
  gperf  \
  dc \
  ranger \
  pv \
  nano \
  httpie \
  black \
  sqlite3 \
  pgcli \
  btop \
  iftop \
  emacs-nox \
  units \
  w3m \
  libpcsclite-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean


ARG USER_UID=1000
ARG USER_GID=1000
ARG USERNAME=oxx
ARG USERHOME=/home/${USERNAME}

####### Install a newer pipx supporting multiple arguments
# RUN python3 -m pip install --break-system-packages pipx

RUN groupadd -g ${USER_UID} ${USERNAME} && \
  useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USERNAME}

##################### CHANGE USER ###################################
USER ${USERNAME}:${USERNAME}
WORKDIR ${USERHOME}
RUN mkdir -p ${USERHOME}/gitdir ${USERHOME}/work ${USERHOME}/.bashrc_zen.d ${USERHOME}/.local
ENV PATH="${USERHOME}/.local/bin:${USERHOME}/go/bin:${USERHOME}/.cargo/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin"


RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C /home/${USERNAME}/.local --strip-components=1 -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz

RUN mkdir -p /home/${USERNAME}/.config/nvim
RUN git clone https://github.com/LazyVim/starter ~/.config/nvim

# Create gitdir with proper ownership BEFORE switching users
# ENTRYPOINT ["/bin/sleep"]
# CMD ["100000"]
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
