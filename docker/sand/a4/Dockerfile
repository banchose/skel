FROM python:trixie


ENV TZ=America/New_York
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8


## LOCALE UTF-8
RUN apt update && apt install -y locales && \
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen \
    bash \
    bash-completion && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean


RUN apt update && apt install -y \
git \
bind9-dnsutils \
iproute2 \
vim-nox \
emacs-nox \
ripgrep \
jq \
fd-find \
fzf \
mtr-tiny \
vim \
gawk \
curl && \
rm -rf /var/lib/apt/lists/* && \
apt-get clean

COPY <<EOF /root/foo
foo
bar
EOF

WORKDIR /root

COPY <<EOF .inputrc
\$include /etc/inputrc
set bell-style none
"\\C-p":history-search-backward
"\\C-n":history-search-forward
set editing-mode vi
\$if mode=vi
    set keymap vi-command
    "G": end-of-history
    set keymap vi-insert
    "jj": vi-movement-mode
    "\\C-o": operate-and-get-next
    set show-mode-in-prompt on
    \$if term=linux
set vi-ins-mode-string \\1\\e[?0c\\2
set vi-cmd-mode-string \\1\\e[?8c\\2
    \$else
set vi-ins-mode-string \\1\\e[6 q\\2
set vi-cmd-mode-string \\1\\e[2 q\\2
    \$endif
\$endif
set show-all-if-ambiguous on
set show-all-if-unmodified on
set completion-ignore-case on
"\\t": menu-complete
"\\e[Z": menu-complete-backward
set colored-stats On
set visible-stats On
set mark-symlinked-directories On
set mark-directories on
set colored-completion-prefix On
set menu-complete-display-prefix On
EOF

COPY <<EOF .bashrc
alias grep='grep -i'
alias g='grep -i'
alias ls='ls -ltr'
alias l='ls -altrt'
alias cp='cp --preserve-root -v'
alias mv='mv --preserve-root -v'
alias v='vim'
EOF

RUN useradd -ms /bin/bash uoo

ENV USERNAME=uoo
ENV USERHOME=/home/${USERNAME}

USER ${USERNAME}

WORKDIR ${USERHOME}

COPY <<EOF .inputrc
\$include /etc/inputrc
set bell-style none
"\\C-p":history-search-backward
"\\C-n":history-search-forward
set editing-mode vi
\$if mode=vi
    set keymap vi-command
    "G": end-of-history
    set keymap vi-insert
    "jj": vi-movement-mode
    "\\C-o": operate-and-get-next
    set show-mode-in-prompt on
    \$if term=linux
set vi-ins-mode-string \\1\\e[?0c\\2
set vi-cmd-mode-string \\1\\e[?8c\\2
    \$else
set vi-ins-mode-string \\1\\e[6 q\\2
set vi-cmd-mode-string \\1\\e[2 q\\2
    \$endif
\$endif
set show-all-if-ambiguous on
set show-all-if-unmodified on
set completion-ignore-case on
"\\t": menu-complete
"\\e[Z": menu-complete-backward
set colored-stats On
set visible-stats On
set mark-symlinked-directories On
set mark-directories on
set colored-completion-prefix On
set menu-complete-display-prefix On
EOF

COPY <<EOF .bashrc
alias grep='grep -i'
alias g='grep -i'
alias ls='ls -ltr'
alias l='ls -altrt'
alias cp='cp --preserve-root -v'
alias mv='mv --preserve-root -v'
alias v='vim'
EOF


CMD ["bash", "-l"]
