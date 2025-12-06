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
RUN adduser -D -s /bin/bash loon
USER loon
WORKDIR /home/loon
COPY inputrc /home/loon/.inputrc
ENTRYPOINT ["/bin/bash"]
CMD ["-l"]
# CMD ["-v"]
