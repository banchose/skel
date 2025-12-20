# Build stage
FROM python:trixie AS builder

RUN apt update && apt install -y \
    ninja-build \
    cmake \
    tree-sitter-cli \
    gcc \
    make \
    unzip \
    build-essential \
    curl \
    git

RUN apt update && apt install -y \
    pipx

WORKDIR /build

RUN git clone --depth=1 https://github.com/neovim/neovim.git && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make install

# Final stage
FROM python:slim-trixie

COPY --from=builder /usr/local /usr/local

RUN useradd -ms /bin/bash lulu

ARG USER=lulu
ARG USERHOME=/home/${USER}

COPY inputrc .inputr

ENV PATH=${USERHOME}/.cargo/bin:${USERHOME}/.local/bin:${PATH}

USER lulu

WORKDIR /home/lulu

COPY inputrc /root/.inputrc

ENV PATH=${USERHOME}/.cargo/bin:${USERHOME}/.local/bin:${PATH}

RUN python3 -m pip install pipx

RUN pipx install uv

RUN nvim --version

# CMD ["nvim"]
# ---- #
CMD ["bash", "-l"]
