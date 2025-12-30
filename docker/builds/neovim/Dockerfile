FROM python:trixie

RUN apt update && apt install -y \
ninja-build \
cmake \
gcc \
make \
unzip \
bash \
bash-completion \
build-essential \
curl \
git

RUN git clone --depth=1 https://github.com/neovim/neovim.git && \
cd neovim && \
make CMAKE_BUILD_TYPE=Release && \
make install

ENV USERNAME=voohoo
ENV USERHOME=/home/${USERNAME}

RUN useradd -ms /bin/bash ${USERNAME}

USER ${USERNAME}
WORKDIR ${USERHOME}

ENTRYPOINT ["nvim"]


