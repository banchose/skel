FROM python:slim

ARG USERNAME=boox
ARG USERHOME=/home/${USERNAME}

RUN apt update && apt install -y \
  curl \
  vim \
  zsh \
  bash \
  bash-completion

RUN useradd -ms /bin/bash ${USERNAME}

USER ${USERNAME}
WORKDIR ${USERHOME}

RUN mkdir -p ${USERHOME}/.local
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C ${USERHOME}/.local --strip-components=1 -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz

ENV PATH="${USERHOME}/.local/bin:$PATH"

RUN python3 -m pip install pipx \
pipx ensurepath && \
pipx install ipython --include-deps && \
pipx inject ipython httpx networkx twisted

COPY --chown=${USERNAME}:${USERNAME} bashrc ${USERHOME}/.bashrc
COPY --chown=${USERNAME}:${USERNAME} inputrc ${USERHOME}/.inputrc
RUN mkdir -p ${USERHOME}/Docker
COPY --chown=${USERNAME}:${USERNAME} Dockerfile ${USERHOME}/Dockerfile

RUN <<EOF
echo "Hello" >> $HOME/hello
echo "World!" >> $HOME/hello
EOF

RUN cat <<EOF >> ${USERHOME}/boom
one
two
three
EOF

RUN bash -c 'cat <<EOF >> Kaaaa \
four \
five \
six \
EOF'

CMD ["bash", "-l"]
