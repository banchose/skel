FROM node:24-bookworm-slim
ARG UID=1002
ARG GID=1002
ARG TARGETARCH

RUN set -eux; \
  rm -f /etc/dpkg/dpkg.cfg.d/docker /etc/dpkg/dpkg.cfg.d/excludes

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       bash ca-certificates git ripgrep \
       man-db manpages manpages-dev less \
  && apt-get install -y --reinstall --no-install-recommends \
       bash coreutils procps gpg socat python3 python3-pip python3-yaml \
       ffmpeg sox libsox-fmt-all dpkg dnsutils bc qalc ipcalc iproute2 \
       fd-find findutils grep iputils-ping tmux jq xz-utils zip gzip unzip \
       7zip bash-completion sed tar util-linux vim curl wget \
  && rm -rf /var/lib/apt/lists/*

RUN mandb -c

ARG JQ_VERSION=1.8.2
RUN set -eux; \
  base="https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}"; \
  f="jq-linux-${TARGETARCH}"; cd /tmp; \
  curl -fsSLo "$f" "$base/$f"; curl -fsSLo sha256sum.txt "$base/sha256sum.txt"; \
  grep " $f\$" sha256sum.txt | sha256sum -c -; \
  install -m 0755 "$f" /usr/local/bin/jq; rm -f "$f" sha256sum.txt; jq --version

ARG SHELLCHECK_VERSION=0.11.0
RUN set -eux; \
  case "$TARGETARCH" in amd64) sc_arch=x86_64 ;; arm64) sc_arch=aarch64 ;; *) echo "unsupported arch: $TARGETARCH" >&2; exit 1 ;; esac; \
  curl -fsSL "https://github.com/koalaman/shellcheck/releases/download/v${SHELLCHECK_VERSION}/shellcheck-v${SHELLCHECK_VERSION}.linux.${sc_arch}.tar.xz" \
    | tar -xJ --strip-components=1 -C /usr/local/bin "shellcheck-v${SHELLCHECK_VERSION}/shellcheck"; \
  chmod 0755 /usr/local/bin/shellcheck; shellcheck --version

# pin instead of /latest/ — bump deliberately
ARG YQ_VERSION=v4.47.1
RUN wget -qO /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${TARGETARCH}" \
  && chmod +x /usr/local/bin/yq && yq --version

RUN npm install -g neovim

RUN mkdir -p /home/node/.pi/agent /workspace && chown -R node:node /home/node/.pi /workspace
RUN set -eux; \
  if [ "$GID" != "$(id -g node)" ]; then groupmod -g "$GID" node; fi; \
  if [ "$UID" != "$(id -u node)" ]; then usermod -u "$UID" -g "$GID" node; fi; \
  chown -R "$UID:$GID" /home/node

USER node
ENV HOME=/home/node PAGER=less MANPAGER=less TZ=America/New_York
ENV PATH="/home/node/.local/bin:${PATH}"

# astral publishes versioned installer URLs; pin it
ARG UV_VERSION=0.12.20
RUN curl -LsSf "https://astral.sh/uv/${UV_VERSION}/install.sh" | sh

ARG NVIM_VERSION=v0.12.5
RUN set -eux; \
  case "$TARGETARCH" in amd64) nv_arch=x86_64 ;; arm64) nv_arch=arm64 ;; *) echo "unsupported arch: $TARGETARCH" >&2; exit 1 ;; esac; \
  mkdir -p "$HOME/.local"; \
  curl -fsSL "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${nv_arch}.tar.gz" \
    | tar -xz --strip-components=1 -C "$HOME/.local"; \
  nvim --version

RUN for t in httpie cfn-lint csvkit litecli pgcli sqlite-utils pylint flake8 mycli psutils \
             strip-tags visidata pynvim yamllint shell-functools ruff black git-filter-repo jc html2text; do \
      uv tool install "$t"; done

# ---- Pi: last expensive layer. Only this and below rebuild on a version bump. ----
USER root
ARG PI_VERSION=latest
RUN HOME=/root npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@${PI_VERSION}"
USER node

COPY --chown=node:node gitconfig /home/node/.gitconfig
COPY --chown=node:node gitignore /home/node/.gitignore
COPY --chown=node:node inputrc /home/node/.inputrc
COPY --chown=node:node bash_aliases /home/node/.bash_aliases
WORKDIR /workspace
ENTRYPOINT ["pi"]
