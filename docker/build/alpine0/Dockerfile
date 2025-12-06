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
RUN apk add --no-cache pipx
RUN apk add --no-cache grep
RUN apk add --no-cache gawk
RUN apk add --no-cache sed
RUN apk add --no-cache rsync
RUN apk add --no-cache iproute2
RUN apk add --no-cache bash
RUN apk add --no-cache bash-completion
RUN apk add --no-cache tmux
RUN apk add --no-cache procps
RUN apk add --no-cache findutils     # GNU find
RUN apk add --no-cache procps-ng     # ps, top, etc.
RUN apk add --no-cache diffutils     # GNU diff
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
RUN adduser -D -s /bin/bash loon
USER loon
WORKDIR /home/loon/gitdir
RUN git clone https://github.com/banchose/skel
WORKDIR /home/loon
COPY inputrc /home/loon/.inputrc
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
