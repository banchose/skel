# syntax=docker/dockerfile:1
FROM rust:1-slim-bookworm AS builder

RUN apt-get update && apt-get install -y \
    git \
    libclang-dev \
    && rm -rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/usr/local/cargo/registry \
    --mount=type=cache,target=/usr/local/cargo/git \
    cargo install --locked tree-sitter-cli

FROM debian:bookworm-slim AS final

RUN apt-get update && apt-get install -y \
    bash \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user0

USER user0

COPY --from=builder /usr/local/cargo/bin/tree-sitter /usr/local/bin/tree-sitter

ENTRYPOINT ["tree-sitter"]
CMD ["--help"]
