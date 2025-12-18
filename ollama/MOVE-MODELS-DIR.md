# How to move ollama models directory elsewhere


- **Edit** the unit file to modifiy the enviromental variable `OLLAMA_MODELS`
- Mind the placement - at the top
- `chown -R ollama:ollama dest`
- `chmod -r 755 dest`

```sh
### Editing /etc/systemd/system/ollama.service.d/override.conf
### Anything between here and the comment below will become the contents of the drop-in file

[Service]
Environment="OLLAMA_MODELS=/dsk/n1/ollama_models"

### Edits below this comment will be discarded


### /etc/systemd/system/ollama.service
# [Unit]
# Description=Ollama Service
# After=network-online.target
#
# [Service]
# ExecStart=/usr/local/bin/ollama serve
# User=ollama
# Group=ollama
# Restart=always
# RestartSec=3
# Environment="PATH=/home/una/.local/bin:/home/una/.local/bin:/home/una/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/var/lib/flatpak/exports/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/home/una/.npm-global/bin:/home/una/.npm-global/bin"
#
# [Install]
# WantedBy=default.target
```
