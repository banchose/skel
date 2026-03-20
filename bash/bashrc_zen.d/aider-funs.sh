# https://aider.chat/docs/install.html
# https://github.com/Aider-AI/aider
# python -m pip install aider-install
# aider-install


aider_run() {
  aider --model sonnet --api-key anthropic="${ANTHROPIC_API_KEY}"
}

aider_help() {

  cat<<EOF
aider --dark-mode
.aider.conf.yml: dark-mode: true

export AIDER_DARK_MODE=true
.env: AIDER_DARK_MODE=true

}


