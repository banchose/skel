FROM debian:latest

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
      vim \
      bash

RUN useradd -ms /bin/bash woo

USER woo
WORKDIR /home/woo

ENV USER=woo
ENV USERHOME=/home/${USER}

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

# Use neovim as the default editor.
ENV EDITOR=nvim \
    VISUAL=nvim

