# docker run -it -v ~/temp:/home/loon/temp --hostname alpine0 --rm alpine0:latest



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
neovim \
py3-pynvim \
python3-dev \
py3-pip \
7zip \
7zip-doc \
zsh \
pipx \
grep \
lsof \
gawk \
sed \
rsync \
iproute2 \
bash \
bash-completion \
yt-dlp-bash-completion \
yt-dlp-zsh-completion \
zathura-bash-completion \
zathura-zsh-completion \
git-zsh-completion \
git-bash-completion \
black-bash-completion \
black-zsh-completion \
bat-zsh-completion \
bat-bash-completion \
tmux \
findutils \
dateutils \
procps-ng \
diffutils \
coreutils \
binutils  \
util-linux \
file \
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
rust cargo rust-doc \
go go-doc \
aws-cli aws-cli-bash-completion aws-cli-doc aws-cli-pyc aws-cli-zsh-completion amazon-ssm-agent \
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
# RUN git clone --depth=1 https://github.com/neovim/neovim
RUN git clone --depth=1 https://github.com/lazyvim/starter
COPY bash_profile /home/loon/.bash_profile
COPY bashrc /home/loon/.bashrc
COPY inputrc /home/loon/.inputrc
COPY tmux.conf /home/loon/.tmux.conf
COPY gitconfig /home/loon/.gitconfig
# WORKDIR /home/loon/gitdir/neovim
# RUN make CMAKE_BUILD_TYPE=RelWithDebInfo
# RUN make install
USER root
WORKDIR /root
RUN apk add --no-cache py3-requests \
py3-beautifulsoup4 \
shellcheck \
shellcheck-doc \
wireshark-doc \
zathura \
zathura-doc \
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
tar-doc \
less-doc \
gzip-doc \
s3cmd \
gcc-doc \
make-doc \
iproute2-doc \
perl-doc \
yt-dlp

USER loon
WORKDIR /home/loon
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
