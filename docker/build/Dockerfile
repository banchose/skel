FROM alpine:latest as builder
WORKDIR /work
RUN apk add git tmux bash bash-completion
RUN apk add ninja-build gcc make cmake unzip gettext-dev curl musl-dev linux-headers
RUN apk add cargo rust
RUN git clone --depth 1 https://github.com/neovim/neovim.git
WORKDIR /work/neovim
# RUN make CMAKE_BUILD_TYPE=RelWithDebInfo &>/dev/null
RUN make CMAKE_BUILD_TYPE=RelWithDebInfo
RUN make install

