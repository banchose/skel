FROM ubuntu:25.04
RUN apt update
RUN apt install -y ninja-build \
    gettext \
    cmake \
    unzip \
    autoconf \
    fd-find \
    fzf \
    ripgrep \
    luajit \
    lua5.1-doc \
    python3-dev \
    liblua5.1-0-dev \
    automake \
    pkg-config \
    bash \
    tmux \
    unzip \
    zip \
    libtool-bin \
    libtool \
#   build-essential \
    git \
    curl

## LAZY NEOVIM ####################
RUN git clone --depth=1 --branch stable https://github.com/neovim/neovim && \
    cd neovim && \
    CFLAGS="-Wno-error=format-truncation" make CMAKE_BUILD_TYPE=Release && \
    make install && \
    rm -rf $USER_HOME/./neovim

ARG USER_NAME=umma
ARG USER_HOME=/home/${USER_NAME}

RUN useradd -m -s /bin/bash "${USER_NAME}"

USER "${USER_NAME}"
COPY --chown="${USER_NAME}":"${USER_NAME}" bashrc "${USER_HOME}"/.bashrc
COPY --chown="${USER_NAME}":"${USER_NAME}" inputrc "${USER_HOME}"/.inputrc
COPY --chown="${USER_NAME}":"${USER_NAME}" tmux.conf "${USER_HOME}"/.tmux.conf
# COPY --chown="${USER_NAME}":"${USER_NAME}" tmux "${USER_HOME}"/.tmux

WORKDIR "${USER_HOME}"

## SET PATH ####################
ENV PATH ${USER_HOME}/.local/bin:${USER_HOME}/go/bin:${USER_HOME}/.cargo/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin

## SET SHELL BASH ####################
SHELL ["/bin/bash", "-o", "pipefail", "-c"]


## GET RUST ####################
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

## GET NVM ####################

ENV BASH_ENV ${USER_HOME}/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install

## GIT SKEL ####################
RUN mkdir -p ${USER_HOME}/gitdir || true && \
  cd ${USER_HOME}/gitdir && \
  git clone https://github.com/banchose/skel

RUN mkdir -p ${USER_HOME}/gitdir || true && \
  mkdir -p $USER_HOME/.config/nvim || true && \
  git clone --depth 1 https://github.com/AstroNvim/template ${USER_HOME}/.config/nvim && \
  rm -rf ${USER_HOME}/.config/nvim/.git


RUN mkdir -p $HOME/.bashrc_zen.d && \
    cd $HOME/.bashrc_zen.d && \
    ln -s $HOME/gitdir/skel/bash/bashrc_zen.d/nvim.sh && \
    ln -s $HOME/gitdir/skel/bash/bashrc_zen.d/nvim_chooser.sh

RUN cargo install bottom --locked

RUN timeout 60 nvim --headless \
  -c 'normal :' \
  -c 'sleep 15' \
  -c qall || true

RUN echo hello

WORKDIR "${USER_HOME}"

CMD ["bash", "-l"]
