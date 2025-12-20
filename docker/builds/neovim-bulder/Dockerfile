# Build stage
FROM python:trixie AS builder

RUN apt update && apt install -y \
    ninja-build \
    cmake \
    gcc \
    make \
    unzip \
    build-essential \
    curl \
    git

WORKDIR /build
RUN git clone --depth=1 https://github.com/neovim/neovim.git && \
    cd neovim && \
    make CMAKE_BUILD_TYPE=Release && \
    make install

# Final stage
FROM python:slim-trixie

COPY --from=builder /usr/local /usr/local

RUN nvim --version

CMD ["nvim"]
