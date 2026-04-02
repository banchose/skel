# https://aider.chat/docs/install.html
# https://github.com/Aider-AI/aider
# python -m pip install aider-install
# aider-install

aider_run() {
  aider --model sonnet --api-key anthropic="${ANTHROPIC_API_KEY}"
}

aider_help() {

  cat <<EOF
aider --dark-mode
.aider.conf.yml: dark-mode: true

export AIDER_DARK_MODE=true
.env: AIDER_DARK_MODE=true
aider --model claude-sonnet-4-6 --api-key anthropic=$ANTHROPIC_API_KEY 
See: ~/.aider.conf.yml
###
# find configs
###-----------------
echo $AIDER_MODEL
cat ~/.aider.conf.yml 2>/dev/null
cat ~/.config/nvim/.aider.conf.yml 2>/dev/null
grep -r "aider" ~/.config/nvim/lua/plugins/ | grep -i model
###-----------------
model: claude-sonnet-4-6
edit-format: ask
map-tokens: 0
git: false
auto-commits: false
cache-prompts: true
disable-playwright: true
# dry-run: true
# just-check-update: true
# edit-format: chat
# suggest-shell-command: false
# shell completions: outputs the completions
###-----------------
EOF
}
