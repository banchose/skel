FROM debian:latest

RUN apt update && apt install -y \
curl \
jq \
bash \
tar \
git \
tmux \
bash-completion


SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV BASH_ENV /root/.bash_env
RUN touch "${BASH_ENV}"
RUN echo '. "${BASH_ENV}"' >> ~/.bashrc

# Download and install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE="${BASH_ENV}" bash
RUN echo node > .nvmrc
RUN nvm install

RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz && \
    tar -C /usr/ --strip-components=1 -xzf nvim-linux-x86_64.tar.gz && \
    rm nvim-linux-x86_64.tar.gz

RUN mkdir -p /root/.config/nvim
RUN git clone --depth=1 https://github.com/LazyVim/starter /root/.config/nvim && \
rm -rf /root/.config/nvim/.git

# First sync LazyVim and install plugins
# RUN nvim --headless "+Lazy! sync" +qa 2>&1 || true
# Then update tree-sitter parsers (plugins are now installed)
# RUN nvim --headless \
#   "+Lazy! sync" \
#   "+sleep 2" \
#   "+TSInstall all" \
#   +qa
# 

# Ensure Node.js is available first
RUN bash -c "source ${BASH_ENV} && nvim --headless '+Lazy! sync' +qa"

# Install all parsers with sufficient time
RUN bash -c "source ${BASH_ENV} && nvim --headless '+TSInstall all' +qa" || true

# Wait and verify
RUN sleep 5

# Check what was actually installed
RUN bash -c "source ${BASH_ENV} && nvim --headless '+TSInstallInfo' '+sleep 3' +qa" || true
# After installing LazyVim
RUN bash -c "source ${BASH_ENV} && nvim --headless '+Lazy! build blink.cmp' +qa" || true


CMD ["bash", "-l"]
