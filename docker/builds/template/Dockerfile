FROM python:latest

# Defined later in the file
#
# Mind 'docker build -t x . --progress=plan'

ENV TZ=America/New_York
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

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
    net-tools \
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
    nmap \
    socat \
    bat \
    tshark \
    shellcheck \
    fzf \
    zsh \
    dnstracer \
    tcpdump \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN ln -s /usr/bin/batcat /usr/bin/bat

####################################################
# USER
####################################################

ARG USERNAME=foo
ARG USERHOME=/home/${USERNAME}

RUN useradd -ms /bin/bash ${USERNAME}

USER ${USERNAME}
WORKDIR ${USERHOME}

# XDG base directories.
ENV XDG_CACHE_HOME="${USERHOME}/.cache" \
    XDG_CONFIG_HOME="${USERHOME}/.config" \
    XDG_STATE_HOME="${USERHOME}/.local/state" \
    XDG_RUNTIME_DIR="${USERHOME}/.local/run" \
    XDG_DATA_HOME="${USERHOME}/.local/share"

# Make sure this stuff is in the path.
ENV PATH="${USERHOME}/.cargo/bin:${USERHOME}/.local/bin:${USERHOME}/go/bin:$PATH:${USERHOME}/.nvim/bin:$PATH"

RUN python3 -m pip install --user pipx

COPY <<EOF .bash_profile
[[ -f ~/.bashrc ]] && . ~/.bashrc
EOF

COPY <<EOF ${USERHOME}/.bashrc
set -o vi
alias l='ls -alF --color=auto'
alias ltr='ls -altrF --color=auto'
alias v='vim'
alias g='grep -i'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set completion-ignore-case on'
bind '"jj": vi-movement-mode'
bind '"\\t": menu-complete'
bind -m vi-command ".":yank-last-arg
bind 'set show-mode-in-prompt on'
bind 'set bell-style none'
bind 'set colored-stats On'
bind 'set menu-complete-display-prefix On'
bind 'set colored-completion-prefix On'
bind 'set mark-directories on'
bind 'set mark-symlinked-directories On'
bind 'set visible-stats On'
EOF

ENV EDITOR=vim

CMD ["bash"]
