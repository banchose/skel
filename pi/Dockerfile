# bump deliberately; Node 26 = LTS from 2026-10-28, Debian 13 trixie = stable
ARG NODE_IMAGE=node:26-trixie-slim
FROM ${NODE_IMAGE}
ARG UID=1002
ARG GID=1002
ARG TARGETARCH

RUN set -eux; \
  rm -f /etc/dpkg/dpkg.cfg.d/docker /etc/dpkg/dpkg.cfg.d/excludes

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
       bash ca-certificates git xxd zstd tree binutils dos2unix ripgrep \
       man-db manpages manpages-dev less \
       python3-pil librsvg2-bin \
  && apt-get install -y --reinstall --no-install-recommends \
       bash coreutils procps imagemagick file libimage-exiftool-perl qpdf miller netcat-openbsd gettext-base gpg socat python3 python3-pip python3-yaml \
       ffmpeg sox libsox-fmt-all dpkg patch python3-wand dnsutils bc qalc ipcalc iproute2 \
       fd-find findutils grep iputils-ping tmux xz-utils zip gzip unzip \
       7zip bash-completion sed tar util-linux vim curl wget \
  && rm -rf /var/lib/apt/lists/* \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd

# Debian 13's IM7 policy no longer blocks Ghostscript formats; restore the block
# (IM sniffs content, so a PostScript file named .jpg would reach gs).
# PDFs go through pdftoppm / pymupdf / gs directly instead.
RUN set -eux; \
  sed -i 's|</policymap>|  <policy domain="coder" rights="none" pattern="{PS,PS2,PS3,EPS,PDF,XPS}" />\n</policymap>|' \
    /etc/ImageMagick-7/policy.xml; \
  grep -q 'pattern="{PS,PS2,PS3,EPS,PDF,XPS}"' /etc/ImageMagick-7/policy.xml

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
ENV HOME=/home/node PAGER=less MANPAGER=less TZ=America/New_York LANG=C.UTF-8
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

RUN for t in httpie cfn-lint csvkit litecli mypy pyright pytest pgcli sqlite-utils pylint flake8 mycli psutils \
             strip-tags visidata pynvim yamllint shell-functools ruff black git-filter-repo jc html2text; do \
      uv tool install "$t"; done

# ---- Pi: last expensive layer. Only this and below rebuild on a version bump. ----
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
      poppler-utils \
      tesseract-ocr tesseract-ocr-eng \
      ocrmypdf \
      python3-pypdf python3-pdfminer python3-venv \
      python3-openpyxl python3-pandas python3-xlrd python3-odf python3-xlsxwriter \
      python3-scipy python3-lxml python3-regex python3-click python3-tqdm python3-dateutil \
      libreoffice-calc-nogui \
      xxd \
      pandoc \
      sqlite3 \
      sqlite3-tools \
      sqlite3-doc \
      libxml2-utils \
 && rm -rf /var/lib/apt/lists/*

# pip-only libs live in a venv that also sees apt's packages, so Debian's files
# (used by ocrmypdf via /usr/bin/python3) are never overwritten.
# pymupdf from pip (2.x, brings pymupdf4llm); pi-heif satisfies ocrmypdf's metadata.
# formulas[excel]: formula recalculation; its scipy/numpy/lxml/etc. come from apt above,
# so pip only adds schedula, numpy-financial, dictdiffer, ezodf.
RUN python3 -m venv --system-site-packages /opt/pyvenv \
 && /opt/pyvenv/bin/pip install --no-cache-dir pymupdf pdfplumber pi-heif "formulas[excel]"
ENV PATH="/opt/pyvenv/bin:${PATH}"

ARG PI_VERSION=latest
RUN HOME=/root npm install -g --ignore-scripts "@earendil-works/pi-coding-agent@${PI_VERSION}"
USER node

COPY --chown=node:node gitconfig /home/node/.gitconfig
COPY --chown=node:node gitignore /home/node/.gitignore
COPY --chown=node:node inputrc /home/node/.inputrc
COPY --chown=node:node bash_aliases /home/node/.bash_aliases
WORKDIR /workspace
ENTRYPOINT ["pi"]
