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

# Use the latest stable release (v0.11.5)
# RUN git clone --depth=1 --branch v0.11.5 https://github.com/neovim/neovim

# Or use the stable tag (though this can move to newer versions)
RUN git clone --depth=1 --branch stable https://github.com/neovim/neovim
# RUN git clone --depth=1 https://github.com/neovim/neovim

RUN cd neovim && \
  CFLAGS="-Wno-error=format-truncation" make CMAKE_BUILD_TYPE=Release && \
  make install && \
  rm -rf ./neovim

RUN useradd -m -s /bin/bash rama

USER rama
COPY --chown=rama:rama bashrc /home/rama/.bashrc
COPY --chown=rama:rama inputrc /home/rama/.inputrc
COPY --chown=rama:rama tmux.conf /home/rama/.tmux.conf
COPY --chown=rama:rama tmux /home/rama/.tmux

WORKDIR /home/rama
RUN mkdir ~/gitdir && \
  cd ~/gitdir && \
  git clone https://github.com/lazyvim/starter && \
  mkdir -p /home/rama/.config/nvim && \
  cp -r /home/rama/gitdir/starter/. /home/rama/.config/nvim

COPY --chown=rama:rama plugins /home/rama/.config/nvim/lua/plugins

RUN nvim --headless "+Lazy! sync" "+sleep 10" +qa
RUN nvim --headless "+Lazy! sync" "+sleep 10" +qa

WORKDIR /home/rama

CMD ["bash", "-l"]
