tmux_get_tpm() {
  command -v git &>/dev/null || {
    echo "No git"
    return 1
  }
  [[ -d ~/.tmux/plugins/tpm ]] && {
    echo "~/.tmux/plugins/tpm/ already exists"
    return 1
  }
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

# Maybe in the .bashrc to start tmux automatically
# # Check if Bash is running interactively
# if [[ $- == *i* ]]; then
#     # Check if the session is already inside tmux
#     if [ -z "$TMUX" ]; then
#         # Check if Bash is running in a TTY or a pseudoterminal (e.g., /dev/pts/*)
#         if [[ "$(tty)" == /dev/tty* || "$(tty)" == /dev/pts/* ]]; then
#             # Start a new tmux session or attach to an existing one
#             tmux attach-session -t default || tmux new-session -s default
#         fi
#     fi
# fi
