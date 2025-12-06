FROM alpine:latest

WORKDIR /work
# Install additional packages
# Creates a layer per package - some are big if order modified
# RUN pip install --no-cache-dir litellm['proxy']
# RUN pip install --no-cache-dir boto3
# RUN pip install --no-cache-dir ipython
RUN apk update
RUN apk add curl
RUN apk add wget
RUN apk add git
RUN apk add vim
RUN apk add jq
RUN apk add python3-dev
RUN apk add py3-pip
RUN apk add pipx
RUN apk add grep
RUN apk add gawk
RUN apk add sed
RUN apk add rsync
RUN apk add iproute2
RUN apk add bash
RUN apk add bash-completion
RUN apk add tmux
RUN adduser -D -s /bin/bash loon
USER loon
COPY inputrc /root/.inputrc
ENTRYPOINT ["bash"]
# CMD ["-v"]

# Copy new files
# COPY ./my-script.py /app/

# Update configuration
# RUN echo "some config" > /etc/myconfig

# etc...

