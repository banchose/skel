# docker run -it -v ~/temp:/home/loon/temp --hostname alpine0 --rm alpine0:latest

# docker run -it --rm -v ~/temp:/home/loon/temp --hostname alpine0 alpine0:latest


FROM alpine:latest

ARG USER_UID=1002
ARG USER_GID=1002

USER root
WORKDIR /root
# Install additional packages
# Creates a layer per package - some are big if order modified
# RUN pip install --no-cache-dir litellm['proxy']
# RUN pip install --no-cache-dir boto3
# RUN pip install --no-cache-dir ipython
RUN apk update
RUN apk add --no-cache \
bash \
jq \
curl \
wget \
git \
vim \
neovim \
7zip \
7zip-doc \
zsh \
grep \
gawk \
lsof \
sed \
rsync \
linux-headers \
musl-dev \
btrfs-progs \
btrfs-progs-extra \
iproute2 \
bash-completion \
git-zsh-completion \
git-bash-completion \
black-bash-completion \
btrfs-progs-bash-completion \
black-zsh-completion \
k9s \
bat-zsh-completion \
bat-bash-completion \
k9s-bash-completion \
k9s-zsh-completion \
uv-bash-completion \
uv-zsh-completion \
step-cli-bash-completion \
step-cli-zsh-completion \
ruff-zsh-completion \
ruff-bash-completion \
ripgrep-bash-completion \
ripgrep-zsh-completion \
py3-pip-bash-completion \
py3-pip-zsh-completion \
mtr-bash-completion \
fd-bash-completion \
fd-zsh-completion \
tmux \
findutils \
dateutils \
procps-ng \
diffutils \
coreutils \
binutils  \
util-linux \
file \
step-cli \
tree \
tar  \
units \
pandoc-cli \
netcat-openbsd \
gzip \
net-tools \
pstree \
pv \
pwgen \
httpie \
bzip2 \
xz \
less \
ffmpeg \
nano \
ripgrep \
aria2 \
aria2-bash-completion \
openssh \
lazygit \
lazydocker \
fd \
zip \
unzip \
bat \
go \
fzf \
dust \
s3cmd \
socat \
mtr \
tcpdump \
ipcalc \
tshark \
nmap \
nginx \
uv \
htop \
btop \
ncurses \
openssl \
strace \
gnupg \
gettext-dev \
gettext-static \
samurai libtool autoconf automake doxygen make cmake g++ gcc gdb \
gperf \
luajit-dev \
lua5.1-dev \
ipython \
go go-doc \
kubectl kubectl-bash-completion kubectl-zsh-completion \
sqlite litecli \
pgcli \
shellcheck \
s-tui \
emacs-nox \
shellcheck-doc \
wireshark-doc \
w3m \
w3m-doc \
rust \
dateutils-doc \
dust-doc \
httpie-doc \
units-doc \
rust-doc \
mandoc \
ipcalc-doc \
bash-doc \
ffmpeg-doc \
lazygit-doc \
lazydocker \
zsh-doc \
jq-doc \
coreutils-doc \
findutils-doc \
fzf-doc \
diffutils-doc \
lsof-doc \
file-doc \
grep-doc \
netcat-openbsd-doc \
py3-networkx-doc \
gnupg-doc \
go-doc \
gawk-doc \
pv-doc \
ripgrep-doc \
pwgen-doc \
pstree-doc \
neovim-doc \
aria2-doc \
gdb-doc \
sed-doc \
openssh-doc \
pandoc-cli-doc \
bind-doc \
alpine-doc \
openssl-doc \
nmap-nping \
tar-doc \
less-doc \
gzip-doc \
s3cmd \
gcc-doc \
make-doc \
emacs-doc \
iproute2-doc \
perl-doc 

RUN apk add py3-boto3 \
py3-pandas \
py3-scipy \
py3-networkx \ 
py3-twisted \ 
py3-requests \ 
py3-beautifulsoup4 \
py3-pynvim \
python3-dev \
py3-pip \
pipx


RUN apk add --no-cache rust rust-doc cargo cargo-bash-completions

RUN apk add --no-cache aws-cli aws-cli-bash-completion aws-cli-doc aws-cli-pyc aws-cli-zsh-completion amazon-ssm-agent

RUN ARCH=amd64 && \
    PLATFORM=$(uname -s)_$ARCH && \
    curl -sLO "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" && \
    curl -sL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_checksums.txt" | grep $PLATFORM | sha256sum --check && \
    tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && \
    rm eksctl_$PLATFORM.tar.gz && \
    install -m 0755 /tmp/eksctl /usr/local/bin && \
    rm /tmp/eksctl

RUN apk add --no-cache yq-python yt-dlp-bash-completion yt-dlp-zsh-completion yt-dlp 

# Add loon user
RUN addgroup -g ${USER_GID} loon && \
    adduser -D -s /bin/bash -u ${USER_UID} -G loon loon

USER loon
ENV PATH="/home/loon/.local/bin:${PATH}"

RUN pipx install \
litecli \
pycowsay \
flake8 \
pylint \
black \
ruff \
pgcli \
cfn-lint \
icecream \
markitdown \
scrapy \
--pip-args="--upgrade" \
--include-deps

# llm 
RUN pipx install llm --pip-args="--upgrade" --include-deps

# llm inject
RUN pipx inject llm \
llm-anthropic \
llm-tools-exa \
llm-openrouter \
llm-anthropic \
llm llm-gemini \
llm-ollama \
llm-fragments-github \
llm-tools-simpleeval \
llm-cmd-comp \
llm-cmd \
llm-python \
llm-jq \
llm-templates-fabric \
uv \
--pip-args="--upgrade" --include-deps

RUN pipx install \
aider-install \
--pip-args="--upgrade" \
--include-deps


WORKDIR /home/loon/gitdir

RUN git clone --depth=1 https://github.com/banchose/skel
# RUN git clone --depth=1 https://github.com/neovim/neovim
RUN git clone --depth=1 https://github.com/lazyvim/starter

WORKDIR /home/loon

COPY --chown=loon:loon bash_profile ./.bash_profile
COPY --chown=loon:loon bashrc ./.bashrc
COPY --chown=loon:loon inputrc ./.inputrc
COPY --chown=loon:loon tmux.conf ./.tmux.conf
COPY --chown=loon:loon gitconfig ./.gitconfig
COPY --chown=loon:loon awsconfig ./.aws/config

WORKDIR /home/loon/work
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
