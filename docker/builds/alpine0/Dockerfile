FROM alpine:latest

USER root
WORKDIR /root
# Install additional packages
# Creates a layer per package - some are big if order modified
# RUN pip install --no-cache-dir litellm['proxy']
# RUN pip install --no-cache-dir boto3
# RUN pip install --no-cache-dir ipython
RUN apk update
RUN apk add --no-cache \
jq \
curl \
wget \
git \
vim \
python3-dev \
py3-pip \
zsh \
pipx \
grep \
gawk \
sed \
rsync \
iproute2 \
bash \
bash-completion \
tmux \
findutils \
procps-ng \
diffutils \
coreutils \
binutils  \
util-linux \
file \
tree \
tar  \
gzip \
net-tools \
bzip2 \
xz \
less \
nano \
ripgrep \
fd \
zip \
unzip \
bat \
fzf \
dust \
socat \
mtr \
tcpdump \
tshark \
nmap \
nginx \
uv \
htop \
btop \
ncurses \
openssl \
strace \
gettext-dev \
gettext-static \
samurai libtool autoconf automake doxygen make cmake g++ gcc \
gperf \
luajit-dev \
lua5.1-dev \
ipython \
rust cargo rust-doc \
go go-doc \
aws-cli aws-cli-bash-completion aws-cli-doc aws-cli-pyc aws-cli-zsh-completion \
kubectl kubectl-bash-completion kubectl-zsh-completion \
sqlite litecli \
pgcli \
py3-boto3 \
py3-twisted
#
#
RUN adduser -D -s /bin/bash loon
USER loon
WORKDIR /home/loon/gitdir
RUN pipx install llm --pip-args="--upgrade"
RUN pipx inject llm llm-anthropic \
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
howdoi \
httpx \
psutils \
certifi \
uv \
--pip-args="--upgrade"

RUN pipx install litecli \
pycowsay \
flake8 \
pylint \
black \
ruff \
pgcli \
cfn-lint \
--pip-args="--upgrade"
# RUN pipx install aider-chat
RUN git clone --depth=1 https://github.com/banchose/skel
RUN git clone --depth=1 https://github.com/neovim/neovim
RUN git clone --depth=1 https://github.com/lazyvim/starter
COPY bash_profile /home/loon/.bash_profile
COPY bashrc /home/loon/.bashrc
COPY inputrc /home/loon/.inputrc
COPY tmux.conf /home/loon/.tmux.conf
COPY gitconfig /home/loon/.gitconfig
WORKDIR /home/loon/gitdir/neovim
RUN make CMAKE_BUILD_TYPE=RelWithDebInfo
USER root
RUN make install
WORKDIR /root
RUN apk add --no-cache py3-requests \
py3-beautifulsoup4 \
shellcheck \
shellcheck-doc \
wireshark-doc \
rust \
rust-doc \
mandoc \
bash-doc \
zsh-doc \
jq-doc \
coreutils-doc \
findutils-doc \
diffutils-doc \
gawk-doc \
sed-doc \
bind-doc \
alpine-doc \
tar-doc \
gzip-doc \
iproute2-doc \
yt-dlp

USER loon
WORKDIR /home/loon
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
