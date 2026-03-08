# Tree-sitter glibc mismatch fix — Raspberry Pi 5 / Debian Bookworm

**Date:** 2026-03-08  
**Type:** Solved Problem  
**Environment / Scope:** Raspberry Pi 5 (`ns2`), Debian 12 Bookworm, kernel 6.12.47+rpt-rpi-2712, aarch64, LazyVim/nvim-treesitter

* * *

## Summary

Prebuilt `tree-sitter` aarch64 binary requires glibc 2.39; Debian Bookworm ships glibc 2.36. Fix is to build `tree-sitter-cli` from source via Cargo.

## Problem

LazyVim's nvim-treesitter failed to compile parsers (luap, others) with:

```
tree-sitter: /lib/aarch64-linux-gnu/libc.so.6: version 'GLIBC_2.39' not found (required by tree-sitter)
```

## Solution

1.  Install Rust (if not present):
    

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.cargo/env
```

2.  Install build dependency:
    

```bash
sudo apt install libclang-dev
```

3.  Build tree-sitter from source:
    

```bash
cargo install tree-sitter-cli
```

Build took ~3 minutes on the Pi 5.

4.  Verify single binary, no stale copies:
    

```bash
which -a tree-sitter
# should show only: /home/una/.cargo/bin/tree-sitter
```

## Gotchas and Warnings

*   `libclang-dev` is required or the build fails at `rquickjs-sys` / `bindgen` with `Unable to find libclang`.
    
*   `~/.cargo/bin` must be on PATH. Already handled in the skel `.bashrc`:
    

```bash
export PATH="$HOME/.cargo/bin:$PATH" # Cargo
```

*   Do **not** upgrade Bookworm to Trixie just for glibc — this is a nameserver.
    

## References

*   nvim-treesitter: [https://github.com/nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
    
*   tree-sitter-cli crate: [https://crates.io/crates/tree-sitter-cli](https://crates.io/crates/tree-sitter-cli)
    

* * *

## Additions

> Items added outside of a structured update. May be rough, incomplete, or shorthand.  
> These should be integrated into the note body on the next formal update.

_(none yet)_
