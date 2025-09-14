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
    jq \
    llvm \
    git \
    curl \
    cmake \
    && rm -rf /var/lib/apt/lists/*

# Add musl target and components globally
RUN rustup target add x86_64-unknown-linux-musl
RUN rustup component add clippy rustfmt
ENV CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=musl-gcc
