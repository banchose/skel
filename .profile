# ~/.profile: executed by the command interpreter for login shells.
# Not read by bash(1) if ~/.bash_profile or ~/.bash_login exists.

# --- XDG base directories (environment, inherited) ---
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_PICTURES_DIR="$HOME/Pictures"
export XDG_STATE_HOME="$HOME/.local/state"

# --- PATH, guarded so re-sourcing is idempotent ---
path_prepend() {
  case ":$PATH:" in
  *":$1:"*) ;;
  *) [ -d "$1" ] && PATH="$1:$PATH" ;;
  esac
}

path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/go/bin"
export PATH

# --- cargo env (sets PATH internally; safe because guarded above would
#     no-op, but cargo's env script is itself idempotent) ---
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# --- uv env, if present ---
[ -f "$HOME/.local/share/../bin/env" ] && . "$HOME/.local/share/../bin/env"

# --- hand off to .bashrc for interactive bash sessions ---
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
