FROM python:trixie

RUN apt update && apt install -y \
ninja-build \
cmake \
gcc \
make \
unzip \
build-essential \
curl \
git

RUN git clone --depth=1 https://github.com/neovim/neovim.git && \
cd neovim && \
make CMAKE_BUILD_TYPE=Release


