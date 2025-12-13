FROM debian:latest

WORKDIR /work
RUN apt update && apt install -y \
curl \
wget \
jq \
bash \
tar \
zip \
unzip \
git \
tmux \
fd-find \
ripgrep \
build-essential \
bash-completion
RUN useradd -m -s /bin/bash luna

#### USER LUNA
USER luna:luna
WORKDIR /home/luna

###### rust install ########
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

###### nvm install ########
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV BASH_ENV /home/luna/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install

ENV PATH /home/luna/.local/bin:${PATH}

#### LazyVim
RUN git clone --depth=1 https://github.com/LazyVim/starter /home/luna/.config/nvim && \
rm -rf /home/luna/.config/nvim/.git
###### neovim install ######
RUN mkdir -p /home/luna/.local
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C /home/luna/.local --strip-components=1 -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz

RUN mkdir -p /home/luna/.config/nvim/lua/plugins
COPY scripts/oil.lua  /home/luna/.config/nvim/lua/plugins


# First sync LazyVim and install plugins
# RUN nvim --headless "+Lazy! sync" +qa 2>&1 || true
# Then update tree-sitter parsers (plugins are now installed)
# RUN nvim --headless \
#   "+Lazy! sync" \
#   "+sleep 2" \
#   "+TSInstall all" \
#   +qa
# 

RUN bash -c "source ${BASH_ENV} && nvim --headless '+MasonInstall lua-language-server pyright black ruff' +qa" || true

# Ensure Node.js is available first
RUN bash -c "source ${BASH_ENV} && nvim --headless '+Lazy! sync' +qa"

# Install all parsers with sufficient time
RUN bash -c "source ${BASH_ENV} && nvim --headless '+TSInstall all' +qa" || true

# Wait and verify
RUN sleep 5

# After installing LazyVim
RUN bash -c "source ${BASH_ENV} && nvim --headless '+Lazy! build blink.cmp' +qa" || true
RUN bash -c "source ${BASH_ENV} && nvim --headless '+MasonUpdate' +qa" || true
RUN bash -c "source ${BASH_ENV} && nvim --headless '+MasonInstall lua-language-server shellcheck black ruff' +qa" || true

CMD ["bash", "-l"]
