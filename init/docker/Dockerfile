FROM bash

# Copy host files into the container
WORKDIR /root

COPY bashrc /root/.bashrc
COPY inputrc /root/.inputrc

COPY init-pipx.sh .

RUN bash ./init-pipx.sh

# Set working directory (optional)

# Default command
CMD ["bash"]
