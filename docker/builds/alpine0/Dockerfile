FROM alpine:latest

USER root
WORKDIR /root
# Install additional packages
# Creates a layer per package - some are big if order modified
# RUN pip install --no-cache-dir litellm['proxy']
# RUN pip install --no-cache-dir boto3
# RUN pip install --no-cache-dir ipython
RUN apk update
RUN apk add --no-cache curl
RUN apk add --no-cache wget
RUN apk add --no-cache git
RUN apk add --no-cache vim
RUN apk add --no-cache jq
RUN apk add --no-cache python3-dev
RUN apk add --no-cache py3-pip
RUN apk add --no-cache zsh
RUN apk add --no-cache pipx
RUN apk add --no-cache grep
RUN apk add --no-cache gawk
RUN apk add --no-cache sed
RUN apk add --no-cache rsync
RUN apk add --no-cache iproute2
RUN apk add --no-cache bash
RUN apk add --no-cache bash-completion
RUN apk add --no-cache tmux
RUN apk add --no-cache findutils     # GNU find
RUN apk add --no-cache procps-ng     # ps, top, etc.
RUN apk add --no-cache diffutils     # GNU diff
RUN apk add --no-cache coreutils     # GNU diff
RUN apk add --no-cache binutils     # GNU
RUN apk add --no-cache util-linux     # GNU
RUN apk add --no-cache file     # GNU
RUN apk add --no-cache tree     # GNU
RUN apk add --no-cache tar     # GNU
RUN apk add --no-cache gzip     # GNU
RUN apk add --no-cache net-tools
RUN apk add --no-cache bzip2
RUN apk add --no-cache xz
RUN apk add --no-cache less
RUN apk add --no-cache nano
RUN apk add --no-cache ripgrep
RUN apk add --no-cache fd
RUN apk add --no-cache zip
RUN apk add --no-cache unzip
RUN apk add --no-cache bat
RUN apk add --no-cache fzf
RUN apk add --no-cache dust
RUN apk add --no-cache socat
RUN apk add --no-cache mtr
RUN apk add --no-cache tcpdump
RUN apk add --no-cache tshark
RUN apk add --no-cache nmap
RUN apk add --no-cache nginx
RUN apk add --no-cache uv
RUN apk add --no-cache htop
RUN apk add --no-cache btop
RUN apk add --no-cache ncurses
RUN apk add --no-cache openssl
RUN apk add --no-cache strace
RUN apk add --no-cache gettext-dev
RUN apk add --no-cache gettext-static
RUN apk add --no-cache samurai libtool autoconf automake doxygen make cmake g++ gcc
RUN apk add --no-cache gperf
RUN apk add --no-cache luajit-dev
RUN apk add --no-cache lua5.1-dev
RUN apk add --no-cache ipython
RUN apk add --no-cache rust cargo rust-doc
RUN apk add --no-cache go go-doc
RUN adduser -D -s /bin/bash loon
USER loon
WORKDIR /home/loon/gitdir
RUN git clone --depth=1 https://github.com/banchose/skel
RUN git clone --depth=1 https://github.com/neovim/neovim
RUN git clone --depth=1 https://github.com/lazyvim/starter
WORKDIR /home/loon/gitdir/neovim
RUN make CMAKE_BUILD_TYPE=RelWithDebInfo
USER root
RUN make install
USER loon
WORKDIR /home/loon
COPY inputrc /home/loon/.inputrc
COPY bash_profile /home/loon/.bash_profile
COPY bashrc-minimal /home/loon/.bashrc
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
