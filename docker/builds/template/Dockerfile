FROM python:latest

# Defined later in the file
#
# Mind 'docker build -t x . --progress=plan'

ENV TZ=America/New_York
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

USER root
ENV USERNAME=root
ENV USERHOME=/${USERNAME}

## LOCALE UTF-8
RUN apt update && apt install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

RUN apt-get update && apt-get install -y \
    curl \
    bash \
    wget \
    git \
    jq \
    gawk \
    sed \
    iproute2 \
    iputils-ping \
    traceroute \
    bind9-dnsutils \
    mtr-tiny \
    zip \
    hexedit \
    unzip \
    fd-find \
    git \
    ripgrep \
    vim-nox \
    tmux \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    bash \
    bash-completion \
    zsh \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


RUN apt-get update && apt-get install -y \
      net-tools \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


RUN apt-get update && apt-get install -y \
      nmap \
      socat \
      tshark \
      tcpdump \
      && rm -rf /var/lib/apt/lists/* \
      && apt-get clean
    

RUN apt-get update && apt-get install -y \
      bat \
      jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN apt-get update && apt-get install -y \
      shellcheck \
      fzf \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean


RUN apt-get update && apt-get install -y \
    dnstracer \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN ln -s /usr/bin/batcat /usr/bin/bat

####################################################
# USER
####################################################

ENV USERNAME=foo
ENV USERHOME=/home/${USERNAME}

RUN useradd -ms /bin/bash ${USERNAME}

USER ${USERNAME}

WORKDIR ${USERHOME}

ENV HOME=${USERHOME}

# XDG base directories.
ENV XDG_CACHE_HOME="${USERHOME}/.cache" \
    XDG_CONFIG_HOME="${USERHOME}/.config" \
    XDG_STATE_HOME="${USERHOME}/.local/state" \
    XDG_RUNTIME_DIR="${USERHOME}/.local/run" \
    XDG_DATA_HOME="${USERHOME}/.local/share"

# Make sure this stuff is in the path.
ENV PATH="${USERHOME}/.nvim/bin:$PATH \
    ${USERHOME}/.cargo/bin:$PATH \
    ${USERHOME}/.local/bin:$PATH \
    ${USERHOME}/go/bin:$PATH \
    $PATH"

COPY --chown=${USERNAME}:${USERNAME} bashrc ${USERHOME}/.bashrc
COPY --chown=${USERNAME}:${USERNAME} inputrc ${USERHOME}/.inputrc

RUN python3 -m pip install --user pipx

# Use neovim as the default editor.
ENV EDITOR=nvim \
    VISUAL=nvim

ENTRYPOINT ["bash"]
CMD ["-l"]
