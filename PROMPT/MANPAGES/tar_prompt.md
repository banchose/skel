# `tar` — GNU Tape Archiver

## Synopsis

```

tar {A|c|d|r|t|u|x} [OPTIONS] [FILE...]

```

## Operation Modes

| Flag | Long | Action |

|------|------|--------|

| `-c` | `--create` | Create archive |

| `-x` | `--extract` | Extract archive |

| `-t` | `--list` | List contents |

| `-r` | `--append` | Append files to archive |

| `-u` | `--update` | Append newer files only |

| `-A` | `--catenate` | Concatenate archives |

| `-d` | `--diff` | Compare archive vs filesystem |

| | `--delete` | Remove members from archive |

## Compression Flags

| Flag | Long | Program |

|------|------|---------|

| `-z` | `--gzip` | gzip |

| `-j` | `--bzip2` | bzip2 |

| `-J` | `--xz` | xz |

| | `--zstd` | zstd |

| | `--lzip` | lzip |

| `-Z` | `--compress` | compress |

| `-a` | `--auto-compress` | Infer from suffix |

| `-I` | `--use-compress-program=CMD` | Arbitrary filter |

**Critical constraint:** `-r`, `-u`, `-A`, `--delete` **do not work on compressed archives**. You must operate on uncompressed `.tar` first, then compress.

## Common Patterns

```bash

# Create gzipped archive

tar czf archive.tar.gz /path/to/dir

# Extract gzipped archive

tar xzf archive.tar.gz

# Extract to specific directory

tar xzf archive.tar.gz -C /target/dir

# List contents

tar tzf archive.tar.gz

# Create with excludes

tar czf archive.tar.gz --exclude='*.log' --exclude='dir/subdir' /path

# Create from file list (find pipeline)

find /path -type f -print0 | tar czf archive.tar.gz --null -T -

# Extract single file

tar xzf archive.tar.gz path/to/specific/file

# Verbose with full timestamps

tar xzvf archive.tar.gz --full-time

```

## Key Options

| Option | Purpose |

|--------|---------|

| `-f FILE` | Archive file (required unless piping) |

| `-v` | Verbose (stackable up to 3x) |

| `-C DIR` | Change dir before operation (order-sensitive) |

| `-T FILE` | Read filenames from FILE |

| `--null` | NUL-delimited input (pair with `find -print0`) |

| `-P` | Preserve absolute paths (don't strip leading `/`) |

| `-p` | Preserve permissions (default for root) |

| `--same-owner` | Preserve ownership (default for root) |

| `--no-same-owner` | Extract as current user |

| `-k` | Don't overwrite existing files |

| `--skip-old-files` | Same as `-k` but silent |

| `-S` | Handle sparse files efficiently |

| `-h` | Follow symlinks |

| `--one-file-system` | Don't cross filesystem boundaries |

| `--strip-components=N` | Strip N leading path components on extract |

| `--transform=EXPR` | sed-style path rewriting |

| `--remove-files` | Delete source files after archiving |

| `-W` | Verify after writing |

| `--totals` | Print byte totals |

| `--sort=name` | Deterministic/reproducible archive ordering |

| `--sort=inode` | Faster creation (fewer seeks on HDD) |

## Exclude/Include

```bash

# Glob pattern

--exclude='PATTERN'

# Exclude from file

--exclude-from=FILE

# Exclude VCS dirs (.git, .svn, etc.)

--exclude-vcs

# Exclude using VCS ignore files (.gitignore, etc.)

--exclude-vcs-ignores

# Exclude backup files (*~, *.bak, etc.)

--exclude-backups

# Exclude cache dirs (CACHEDIR.TAG)

--exclude-caches

```

## Incremental Backups

```bash

# Level 0 (full) — creates snapshot file

tar czf full.tar.gz -g snapshot.snar /data

# Level 1 (incremental) — uses copy of snapshot

cp snapshot.snar snapshot.snar.1

tar czf incr.tar.gz -g snapshot.snar.1 /data

# Extract incremental (use /dev/null for snapshot arg)

tar xzf incr.tar.gz -g /dev/null

```

## Extended Attributes

```bash

# Preserve ACLs, SELinux, xattrs

tar czf archive.tar.gz --acls --selinux --xattrs /path

# Filter xattrs

--xattrs-include='user.*'

--xattrs-exclude='security.*'

```

## Remote Archives

```bash

# Via rsh/ssh

tar czf remotehost:/path/archive.tar.gz /local/path

--rsh-command=/usr/bin/ssh

```

## Encryption (Community Practice)

tar has no built-in encryption. Standard approaches:

```bash

# GPG symmetric (recommended for personal use)

tar cf - /data | gpg --symmetric --compress-algo none -o backup.tar.gpg

# Decrypt

gpg --decrypt --output backup.tar backup.tar.gpg

# Pipe-based (single pass, no temp file)

tar cz /data | gpg --symmetric --compress-algo none -o backup.tar.gz.gpg

```

- **Use `--compress-algo none` in gpg** when tar already compresses — avoids double-compression and preserves GPG's error recovery properties.

- GPG symmetric preferred over 7zip/zip encryption for algorithm transparency.

- For long-term archives, prefer **bzip2 or lzip** over gzip — they have better recovery from partial corruption.

## Selective Exclude with Partial Include (Workaround)

The problem: exclude a directory but keep specific files within it. `--exclude` + `-r` requires uncompressed intermediate archive.

**Best solution:** use `find` to build the exact file list, pipe to tar:

```bash

find /some \( -path '/some/dir' -prune -o -print0 \) | \

  cat - <(printf '%s\0' some/dir/file1 some/dir/file2 some/dir/dir2) | \

  tar czf backup.tar.gz --null -T -

```

This avoids the two-pass create+append problem entirely.

## Par2 for Archive Integrity

Community consensus for protecting tar archives against bitrot:

```bash

# Create parity (e.g., 5% redundancy)

par2 create -r5 archive.tar.gz

# Verify

par2 verify archive.tar.gz

# Repair

par2 repair archive.tar.gz

```

- Par2 is more efficient on single large files (like a `.tar`) than many small files due to fixed block size.

- Store par2 files separately from the archive (different drive/cloud) for maximum protection.

- Always verify immediately after creation to catch RAM/hardware issues.

- For archives that change, par2 must be regenerated — it's best suited for static/finalized archives.

## Exit Codes

| Code | Meaning |

|------|---------|

| 0 | Success |

| 1 | Files differ (with `-d`) or files changed during archiving |

| 2 | Fatal error |

## Size Suffixes

`b`=×512, `BKk`=×1024, `M`=×1024², `G`=×1024³, `T`=×1024⁴, `P`=×1024⁵, `c`=bytes, `w`=×2