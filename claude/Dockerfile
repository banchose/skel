# docker build -t my-claude-code:latest -t my-claude-code:v1.0 -t my-claude-code:alpine .

FROM alpine:latest

# Install dependencies and Claude Code
RUN apk add --no-cache \
    bash \
    vim \
    openssl \
    lsof \
    shellcheck \
    bash-completion \
    coreutils \
    nginx \
    socat \
    tshark \
    make \
    cmake \
    rsync \
    jq \
    util-linux \
    sed \
    procps \
    tmux \
    git \
    curl \
    wget \
    gcc
    # your other dependencies

# Create non-root user (Alpine syntax)
RUN addgroup -g 1000 appgroup && \
    adduser -u 1000 -G appgroup -h /home/appuser -D appuser

# Set up workspace
WORKDIR /workspace
RUN chown -R appuser:appgroup /workspace

USER appuser
CMD ["/bin/bash"]
