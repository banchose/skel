# WSL Fix: UTF-8 Locale Encoding Artifacts

## Problem

Encoding artifacts appear in terminal output (e.g., `ΓÇö` instead of `—`). This is a locale issue — the WSL environment does not have `en_US.UTF-8` installed.

**Symptom:**

```bash
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
# bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
```

`locale -a` only shows `C`, `C.utf8`, `POSIX` — no `en_US.UTF-8`.

## Fix

### 1. Install locales package (if needed)

```bash
sudo apt-get install locales
```

### 2. Generate the locale

```bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

### 3. Restart the shell

```bash
exec bash
```

### 4. Verify

```bash
locale
```

All `LC_*` entries should show `en_US.UTF-8` with no warnings.

## Notes

*   The `export` commands alone are not sufficient if the locale isn't installed — you must run `locale-gen` first.
    
*   If artifacts persist after the fix, the source file/tool may be outputting Windows-1252 encoded characters rather than UTF-8, which is a separate upstream issue.
