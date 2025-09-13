yum -y install cargo
cargo install fd-find
cargo install ripgrep
cargo install aichat

## Build stage
#FROM rust:slim as builder
#RUN cargo install fd-find ripgrep bat
# Copy binaries to runtime stage..
