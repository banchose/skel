FROM python

WORKDIR /work
# Install additional packages
# Creates a layer per package - some are big if order modified
RUN pip install --no-cache-dir litellm['proxy']
RUN pip install --no-cache-dir boto3
RUN pip install --no-cache-dir ipython
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y git
RUN apt-get install -y vim
RUN apt-get install -y jq
RUN apt-get install -y grep
RUN apt-get install -y gawk
RUN apt-get install -y sed
RUN apt-get install -y rsync
RUN apt-get install -y iproute2
RUN apt-get install -y bash
RUN apt-get install -y bash-completion
RUN apt-get install -y tmux
RUN apt-get clean && \
  rm -rf /var/lib/apt/lists/*
COPY inputrc /root/.inputrc


# Copy new files
# COPY ./my-script.py /app/

# Update configuration
# RUN echo "some config" > /etc/myconfig

# etc...
