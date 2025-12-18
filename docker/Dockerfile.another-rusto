# Save as Dockerfile.rust-builder-user
FROM rust:slim

LABEL description="Universal Rust build environment"

# Install build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    libssl-dev \
    musl-tools \
    bash \
    tmux \
    bash-completion \
    musl-dev \
    clang \
    llvm \
    git \
    curl \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Create user with your exact UID/GID
ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USERNAME=rustdev

RUN groupadd -g $GROUP_ID $USERNAME && \
    useradd -m -u $USER_ID -g $GROUP_ID -s /bin/bash $USERNAME

# Switch to your user
USER $USERNAME
WORKDIR /home/$USERNAME

# Add musl target
RUN rustup target add x86_64-unknown-linux-musl
RUN rustup component add clippy rustfmt

ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=musl-gcc
