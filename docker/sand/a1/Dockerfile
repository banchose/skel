FROM python:trixie

# RUN apt update && apt install -y shadow

ARG USER=lulu
ARG USERHOME=/home/${USER}

RUN useradd -ms /bin/bash ${USER}

USER ${USER}

WORKDIR ${USERHOME}

CMD ["ls -alF"]

