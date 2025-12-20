FROM python:slim

ARG USER=choo
ARG USERHOME=/home/${USER}

RUN useradd -ms /bin/bash ${USER}

# USER ${USER}
# WORKDIR ${USERHOME}

COPY <<EOT /script.sh
  set -exuo pipefail
  echo "hello frisco"
  echo "and hello ${USER}"
EOT

ENTRYPOINT ["sh", "/script.sh"]


