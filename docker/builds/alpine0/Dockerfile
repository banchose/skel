FROM python:trixie

ARG USER_UID=1002
ARG USER_GID=1002

### ROOT ###

USER root
WORKDIR /root

RUN apt update && apt install -y \
  bash \
  bash-completion  \
  git \
  iproute2 \
  lsof \
  vim  \
  neovim  \
  zip \
  bzip2 \
  xz-utils \
  fzf \
  unzip \
  7zip \
  ipcalc  \
  tshark \
  nmap \
  mtr  \
  wget  \
  tcpdump \
  socat \
  tmux \
  netcat-openbsd \
  bat \
  vim  \
  ripgrep \
  fd-find \
  shellcheck  \
  zsh  \
  curl

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

RUN apt update && apt install -y \
  python3-pynvim \
  tree \
  btrfs-progs \
  ninja-build \
  meson \
  black


RUN apt update && apt install -y \
  strace \
  htop  \
  btop


RUN apt update && apt install -y \
  units \
  pandoc \
  pwgen \
  pv \
  nano \
  httpie \
  aria2 \
  rclone \
  ffmpeg \
  ffmpeg-doc \
  lazygit

RUN apt update && apt install -y \
 # samurai  \
  libtool \
  autoconf \
  automake \
  doxygen \
  make \
  cmake \
  gcc \
  g++ \
  gdb \
  gperf  \
  golang \
  luajit \
  lua5.1-doc


RUN apt update && apt install -y \
  units \
  sqlite3 \
  pgcli \
  pgcli \
  emacs-nox


RUN apt update && apt install -y \
  units

RUN apt update && apt install -y \
  w3m

RUN apt update && apt install -y \
  s3cmd \
  awscli


RUN apt update && apt install -y \
  pip \
  faker \
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
  pipx

RUN apt update && apt install -y \
  manpages \
  man-db

############### Kubernetes
RUN apt update && apt install -y \
  kubectl

RUN ARCH=amd64 && \
    PLATFORM=$(uname -s)_$ARCH && \
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" && \
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check && \
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && \
    rm eksctl_$PLATFORM.tar.gz && \
    install -m 0755 /tmp/eksctl /usr/local/bin && \
    rm /tmp/eksctl
################

# Add loon user
RUN addgroup --gid ${USER_GID} loon && \
    adduser --disabled-password --shell /bin/bash --uid ${USER_UID} --ingroup loon --gecos "" loon

# Create gitdir with proper ownership BEFORE switching users
RUN mkdir -p /home/loon/gitdir && \
    chown -R loon:loon /home/loon

USER loon
ENV PATH="/home/loon/.local/bin:${PATH}"

RUN pipx install \
pycowsay \
flake8 \
pylint \
black \
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




# llm
RUN pipx install llm \
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


RUN llm models default anthropic/claude-sonnet-4-5

### LOON ####
USER loon
WORKDIR /home/loon
RUN go install github.com/akavel/up@latest
RUN go install github.com/charmbracelet/glow/v2@latest
RUN pipx install visidata 'litellm[proxy]'



WORKDIR /home/loon/gitdir

RUN git clone --depth=1 https://github.com/banchose/skel
# RUN git clone --depth=1 https://github.com/neovim/neovim
RUN git clone --depth=1 https://github.com/lazyvim/starter
RUN git clone --depth=1 https://github.com/gto76/python-cheatsheet
RUN git clone --depth=1 https://github.com/donnemartin/interactive-coding-challenges
RUN git clone --depth=1 https://github.com/realpython/python-guide
RUN git clone --depth=1 https://github.com/yidao620c/python3-cookbook
RUN git clone --depth=1 https://github.com/TheAlgorithms/Python
RUN git clone --depth=1 https://github.com/simonw/llm

WORKDIR /home/loon

COPY --chown=loon:loon bash_profile ./.bash_profile
COPY --chown=loon:loon bashrc ./.bashrc
COPY --chown=loon:loon inputrc ./.inputrc
COPY --chown=loon:loon tmux.conf ./.tmux.conf
COPY --chown=loon:loon gitconfig ./.gitconfig
COPY --chown=loon:loon awsconfig ./.aws/config

WORKDIR /home/loon/work
COPY --chown=loon:loon README-alpine0.md ./
# ENTRYPOINT ["/bin/sleep"]
# CMD ["100000"]
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
