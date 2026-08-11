# Same as Dockerfile.pi.node-user, but with man pages available.
#
# docker build -f Dockerfile.pi.node-user-man -t pi-node-user-man .
#
# docker run --rm -it \
#   -e ANTHROPIC_API_KEY \
#   -v "$PWD:/workspace" \
#   -v pi-agent-home:/home/node/.pi/agent \
#   pi-node-user-man

FROM node:24-bookworm-slim
ARG UID=1002
ARG GID=1002

# Debian slim images ship a dpkg config that excludes man pages / docs.
# Drop those exclusions so anything installed from here on keeps its man pages.
RUN set -eux; \
  if [ -e /etc/dpkg/dpkg.cfg.d/docker ]; then rm -f /etc/dpkg/dpkg.cfg.d/docker; fi; \
  if [ -e /etc/dpkg/dpkg.cfg.d/excludes ]; then rm -f /etc/dpkg/dpkg.cfg.d/excludes; fi

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       bash ca-certificates git ripgrep \
       man-db manpages manpages-dev less \
  # reinstall the base packages so their previously-excluded man pages land on disk
  && apt-get install -y --reinstall --no-install-recommends \
       bash coreutils dpkg findutils grep iputils-ping tmux jq bash-completion sed tar util-linux vim curl wget \
  && rm -rf /var/lib/apt/lists/*

# build the man page index so `man -k` / `apropos` work
RUN mandb -c

# apt only has jq 1.6; ship the official static 1.8.2 binary in /usr/local/bin,
# which precedes /usr/bin on PATH. apt's jq stays for `man jq`.
ARG JQ_VERSION=1.8.2
# sha256 of jq-linux-amd64 from
# https://github.com/jqlang/jq/releases/download/jq-1.8.2/sha256sum.txt
ARG JQ_SHA256=b1c22172dd303f3be49e935aa56aa48a8b7a46e0bc838b4997d3bb451495870f
RUN set -eux; \
  curl -fsSLo /usr/local/bin/jq \
    "https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}/jq-linux-amd64"; \
  echo "${JQ_SHA256}  /usr/local/bin/jq" | sha256sum -c -; \
  chmod 0755 /usr/local/bin/jq
# create the agent dir with correct ownership BEFORE it becomes a volume mountpoint
RUN npm install -g --ignore-scripts @earendil-works/pi-coding-agent
RUN mkdir -p /home/node/.pi/agent && chown -R node:node /home/node/.pi
RUN mkdir -p /workspace && chown node:node /workspace

RUN set -eux; \
     if [ "$GID" != "$(id -g node)" ]; then groupmod -g "$GID" node; fi; \
     if [ "$UID" != "$(id -u node)" ]; then usermod -u "$UID" -g "$GID" node; fi; \
     chown -R "$UID:$GID" /home/node

USER node
ENV HOME=/home/node
ENV PAGER=less
ENV MANPAGER=less
ENV TZ=America/New_York
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
RUN pi install git:github.com/nagisanzenin/engram
ENV PATH="${HOME}/.local/bin:${PATH}"
RUN uv tool install httpie
WORKDIR /workspace
ENTRYPOINT ["pi"]
