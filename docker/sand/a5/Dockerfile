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

WORKDIR /root

COPY inputrc .inputrc


ARG USERNAME=xox
ARG USERHOME=/home/${USERNAME}

RUN useradd -ms /bin/bash uoo

#### SWITCH USER #######

USER ${USERNAME}

WORKDIR ${USERHOME}

COPY inputrc .inputrc

CMD ["bash", "-l"]
