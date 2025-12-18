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

ARG USER_NAME=rama
ARG USER_HOME=/home/${USER_NAME}

RUN useradd -m -s /bin/bash "${USER_NAME}"

USER "${USER_NAME}"
COPY --chown="${USER_NAME}":"${USER_NAME}" bashrc "${USER_HOME}"/.bashrc
COPY --chown="${USER_NAME}":"${USER_NAME}" inputrc "${USER_HOME}"/.inputrc
COPY --chown="${USER_NAME}":"${USER_NAME}" tmux.conf "${USER_HOME}"/.tmux.conf
COPY --chown="${USER_NAME}":"${USER_NAME}" tmux "${USER_HOME}"/.tmux

WORKDIR "${USER_HOME}"

## SET PATH ####################
ENV PATH ${USER_HOME}/.local/bin:${USER_HOME}/go/bin:${USER_HOME}/.cargo/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin


## SET SHELL BASH ####################
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

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
  git clone https://github.com/banchose/skel && \
  git clone --depth 1 https://github.com/nvim-lua/kickstart.nvim && \
  mkdir -p $USER_HOME/.config || true && \
  cp -r $USER_HOME/gitdir/kickstart.nvim $USER_HOME/.config


RUN mkdir ~/gitdir || true  && \
  cd ~/gitdir && \
  git clone https://github.com/lazyvim/starter && \
  mkdir -p "${USER_HOME}"/.config/nvim && \
  cp -r "${USER_HOME}"/gitdir/starter/. "${USER_HOME}"/.config/nvim

COPY --chown="${USER_NAME}":"${USER_NAME}" plugins "${USER_HOME}"/.config/nvim/lua/plugins

RUN nvim --headless \
  "+Lazy! sync" \
  "+sleep 8" \
  "+Lazy! update" \
  "+TSUpdate!" \
  +qa

RUN nvim --headless \
  "+Lazy! update" \
  "+TSUpdate!" \
  "+sleep 5" \
  +qa

RUN timeout 180 nvim --headless \
  -c 'lua require("lazy").setup()' \
  -c 'lua require("mason").setup()' \
  -c 'lua require("mason-lspconfig").setup()' \
  -c 'LspInstall lua_ls' \
  -c 'sleep 30' \
  -c qall || true

# After lazy.nvim sync and LSP installs
RUN timeout 60 nvim --headless \
  -c 'normal :' \
  -c 'sleep 10' \
  -c qall || true

RUN mkdir -p $HOME/.bashrc_zen.d && \
    cd $HOME/.bashrc_zen.d && \
    ln -s $HOME/gitdir/skel/bash/bashrc_zen.d/nvim.sh && \
    ln -s $HOME/gitdir/skel/bash/bashrc_zen.d/nvim_chooser.sh


WORKDIR "${USER_HOME}"

CMD ["bash", "-l"]
