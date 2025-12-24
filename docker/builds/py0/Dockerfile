FROM debian:trixie

# Defined later in the file
# docker build -t py0:latest --build-arg USER_UID="$(id -u)" --build-arg USER_GID="$(id -g)" .

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
  lua5.1 \
  lua5.4 \
  liblua5.1-0-dev \
  liblua5.4-dev \
  luajit \
  lua5.1-doc \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

RUN curl -v -L -o /usr/bin/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && chmod +x /usr/bin/kubectl

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install

RUN curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" && \
dpkg -i session-manager-plugin.deb


RUN ARCH=amd64 && \
    PLATFORM=$(uname -s)_$ARCH && \
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" && \
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check && \
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && \
    rm eksctl_$PLATFORM.tar.gz && \
    install -m 0755 /tmp/eksctl /usr/local/bin && \
    rm /tmp/eksctl

# As root
RUN apt update && apt install -y \
  python3.13-venv \
  pip \
  faker \
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


RUN apt update && apt install -y \
    build-essential cmake autoconf automake libtool pkg-config \
    zlib1g-dev libbz2-dev liblzma-dev libzstd-dev \
    libssl-dev libgcrypt20-dev \
    libxml2-dev libexpat1-dev \
    libfuse-dev libpcsclite-dev \
    libcurl4-openssl-dev \
    libsqlite3-dev \
    libncurses-dev \
    libopenblas-dev \
    liblua5.1-0-dev \
    libpcsclite-dev \
    libopenblas-dev \
    libfuse-dev \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

RUN apt update && apt install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8


RUN apt update && apt install -y  \
    lazygit && \
    rm -rf /var/lib/apt/lists/*
#   apt-get clean


# Install golang - go
RUN wget https://go.dev/dl/go1.25.5.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.25.5.linux-amd64.tar.gz && \
    rm go1.25.5.linux-amd64.tar.gz

RUN cd /tmp && \
wget https://luarocks.org/releases/luarocks-3.12.2.tar.gz && \
tar zxpf luarocks-3.12.2.tar.gz && \
cd luarocks-3.12.2 && \
./configure && make && make install && \
luarocks install luasocket

ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_NAME=loon
ARG USER_HOME=/home/${USER_NAME}

ENV PATH=$PATH:/usr/local/go/bin:${USER_HOME}/go/bin

# Add a 'normal' user
RUN groupadd -g ${USER_UID} ${USER_NAME} && \
  useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash ${USER_NAME}

# Tree-sitter for lazyvim
RUN curl -L https://github.com/tree-sitter/tree-sitter/releases/download/v0.26.3/tree-sitter-linux-x64.gz \
  | gunzip > /usr/local/bin/tree-sitter && \
  chmod +x /usr/local/bin/tree-sitter

##
##
##
##################### CHANGE USER ###################################
##
##
##

USER ${USER_NAME}:${USER_NAME}
ENV PATH="${USER_HOME}/.local/bin:${USER_HOME}/go/bin:${USER_HOME}/.cargo/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin"

####### Install a newer pipx supporting multiple arguments
RUN python3 -m pip install --break-system-packages pipx

RUN mkdir -p ${USER_HOME}/gitdir ${USER_HOME}/work ${USER_HOME}/.bashrc_zen.d

WORKDIR ${USER_HOME}

RUN python3 -m pipx install \
pycowsay \
flake8 \
pylint \
black \
pynvim \
ruff \
pgcli \
cfn-lint \
csvkit \
s3cmd \
ptpython \
posting \
isort \
icecream \
markitdown \
scrapy \
--pip-args="--upgrade" \
--include-deps

RUN curl -fsSL https://claude.ai/install.sh | bash

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# Install golang - go
RUN wget https://go.dev/dl/go1.25.5.linux-amd64.tar.gz && \
    rm -rf ${USER_HOME}/go && \
    tar -C ${USER_HOME} -xzf go1.25.5.linux-amd64.tar.gz && \
    rm go1.25.5.linux-amd64.tar.gz

USER root
# Install Node.js from NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# Verify installation
RUN node --version && npm --version

# Install npm packages globally
RUN npm install -g neovim bash-language-server

USER ${USER_NAME}:${USER_NAME}

# llm
RUN python3 -m pipx install llm \
--pip-args="--upgrade" \
--include-deps

RUN llm install \
llm-anthropic \
llm-tools-exa \
llm-openrouter \
llm-gemini \
llm-bedrock  \
llm-bedrock-anthropic  \
# llm-bedrock-meta  \
# llm-ollama \
llm-tools-quickjs \
llm-tools-sqlite \
llm-tools-rag \
# llm-fragments-pdf \
llm-fragments-site-text \
llm-templates-github \
llm-fragments-github \
llm-tools-simpleeval \
llm-cmd-comp \
llm-cmd \
llm-python \
llm-jq \
llm-templates-fabric

ENV PATH=$PATH:/usr/local/go/bin
RUN go install github.com/akavel/up@latest
RUN go install github.com/charmbracelet/glow/v2@latest
RUN python3 -m pipx install visidata 'litellm[proxy]' --include-deps
RUN python3 -m pipx install pudb
RUN python3 -m pipx install bpython --include-deps


RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C ${USER_HOME}/.local --strip-components=1 -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz

RUN mkdir -p ${USER_HOME}/.config/nvim

RUN git clone https://github.com/LazyVim/starter ~/.config/nvim

RUN nvim --headless \
  "+Lazy! sync" \
  "+sleep 30" \
  "+Lazy! update" \
  "+sleep 30" \
  "+Lazy! sync" \
  "+sleep 5" \
  "+TSUpdate" \
  "+sleep 10" \
  +qa

RUN timeout 180 nvim --headless \
  -c 'lua require("lazy").setup()' \
  -c 'lua require("mason").setup()' \
  -c 'lua require("mason-lspconfig").setup()' \
  -c 'LspInstall lua_ls' \
  -c 'sleep 10' \
  -c qall || true # After lazy.nvim sync and LSP installs

RUN timeout 60 nvim --headless \
  -c 'normal :' \
  -c 'sleep 5' \
  -c qall || true
######
WORKDIR ${USER_HOME}/gitdir
RUN git clone --depth=1 https://github.com/banchose/skel

# RUN git clone --depth=1 https://github.com/neovim/neovim
RUN git clone --depth=1 https://github.com/lazyvim/starter
RUN git clone --depth=1 https://github.com/gto76/python-cheatsheet
RUN git clone --depth=1 https://github.com/donnemartin/interactive-coding-challenges
RUN git clone --depth=1 https://github.com/realpython/python-guide
RUN git clone --depth=1 https://github.com/yidao620c/python3-cookbook
RUN git clone --depth=1 https://github.com/TheAlgorithms/Python
RUN git clone --depth=1 https://github.com/simonw/llm

WORKDIR ${USER_HOME}

COPY --chown=${USER_NAME}:${USER_NAME} bash_profile ${USER_HOME}/.bash_profile
COPY --chown=${USER_NAME}:${USER_NAME} bashrc ${USER_HOME}/.bashrc
# COPY --chown=${USER_NAME}:${USER_NAME} inputrc ${USER_HOME}/.inputrc
# COPY --chown=${USER_NAME}:${USER_NAME} tmux.conf ${USER_HOME}/.tmux.conf
# COPY --chown=${USER_NAME}:${USER_NAME} gitconfig ${USER_HOME}/.gitconfig
# COPY --chown=${USER_NAME}:${USER_NAME} awsconfig ${USER_HOME}/.aws/config

# RUN mkdir -p ${USER_HOME}/.bashrc_zen.d

# COPY --chown=${USER_NAME}:${USER_NAME} dummy_xxx_.sh ${USER_HOME}/.bashrc_zen.d
# RUN ln -s ${USER_HOME}/gitdir/skel/bash/bashrc_zen.d/aws.sh ${USER_HOME}/.bashrc_zen.d
# RUN ln -s ${USER_HOME}/gitdir/skel/bash/bashrc_zen.d/nvim_chooser.sh ${USER_HOME}/.bashrc_zen.d
# RUN ln -s ${USER_HOME}/gitdir/skel/bash/bashrc_zen.d/nvim.sh ${USER_HOME}/.bashrc_zen.d
# RUN ln -s ${USER_HOME}/gitdir/skel/bash/bashrc_zen.d/kubernetes.sh ${USER_HOME}/.bashrc_zen.d
# RUN ln -s ${USER_HOME}/gitdir/skel/bash/bashrc_zen.d/docker.sh ${USER_HOME}/.bashrc_zen.d
# RUN ln -s ${USER_HOME}/gitdir/skel/bash/bashrc_zen.d/llm-cli.sh ${USER_HOME}/.bashrc_zen.d
# RUN ln -s ${USER_HOME}/gitdir/skel/bash/bashrc_zen.d/tmux.sh ${USER_HOME}/.bashrc_zen.d

WORKDIR ${USER_HOME}/work

## Additional user installs
#
# RUN pipx install aider-install && pipx inject aider-install boto3 && aider-install
# RUN pipx install rich-cli --include-deps

COPY --chown=${USER_NAME}:${USER_NAME} README-py0.md ${USER_HOME}/work
# COPY --chown=${USER_NAME}:${USER_NAME} aws ${USER_HOME}/work/aws
COPY --chown=${USER_NAME}:${USER_NAME} scripts/testme.sh ${USER_HOME}/work/scripts/testme.sh
RUN chmod 755 ${USER_HOME}/work/scripts/testme.sh
COPY --chown=${USER_NAME}:${USER_NAME} Dockerfile ${USER_HOME}/work/Docker/Dockerfile
COPY --chown=${USER_NAME}:${USER_NAME} scripts ${USER_HOME}/work/scripts
RUN chmod 755 ${USER_HOME}/work/scripts/init-lazy.sh

# RUN pipx install --include-deps aider-chat && \
# pipx inject aider-chat boto3


COPY --chown=${USER_NAME}:${USER_NAME} settings.json ${USER_HOME}/.claude/settings.json
COPY --chown=${USER_NAME}:${USER_NAME} anthropic_keys.sh ${USER_HOME}/.claude/anthropic_keys.sh
RUN chmod 755 ${USER_HOME}/.claude/anthropic_keys.sh
RUN ls -la ${USER_HOME}/.claude/anthropic_keys.sh
RUN cat ${USER_HOME}/.claude/anthropic_keys.sh

RUN llm models default anthropic/claude-sonnet-4-5

RUN npm install neovim


RUN echo $SHELL

USER ${USER_NAME}
WORKDIR ${USER_HOME}

# Create gitdir with proper ownership BEFORE switching users
# ENTRYPOINT ["/bin/sleep"]
# CMD ["100000"]
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
