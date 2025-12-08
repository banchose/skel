alias update-ollama='ollama list | while read -r col1 rest;do ollama pull "$col1";done'
