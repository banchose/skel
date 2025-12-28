FROM bash:latest

ARG USERNAME=loo
ARG USERHOME=/home/${USERNAME}

RUN apk update && apk add shadow

RUN useradd -ms /bin/bash ${USERNAME}

USER ${USERNAME}
WORKDIR ${USERHOME}

COPY <<EOF .bash_profile
[[ -f ~/.bashrc ]] && . ~/.bashrc
EOF

COPY <<EOF ${USERHOME}/.bashrc
set -o vi
alias l='ls -alF --color=auto'
bind 'set show-all-if-ambiguous on'
bind 'set show-all-if-unmodified on'
bind 'set completion-ignore-case on'
bind '"jj": vi-movement-mode'
bind -m vi-command ".":yank-last-arg
EOF

ENV XDG_CACHE_HOME="${USERHOME}/.cache" \
    XDG_CONFIG_HOME="${USERHOME}/.config" \
    XDG_STATE_HOME="${USERHOME}/.local/state" \
    XDG_RUNTIME_DIR="${USERHOME}/.local/run" \
    XDG_DATA_HOME="${USERHOME}/.local/share"

# Make sure this stuff is in the path.
ENV PATH="${USERHOME}/.nvim/bin:$PATH \
    ${USERHOME}/.cargo/bin:$PATH \
    ${USERHOME}/.local/bin:$PATH \
    ${USERHOME}/go/bin:$PATH \
    $PATH"

ENTRYPOINT ["bash"]
CMD ["-l"]
