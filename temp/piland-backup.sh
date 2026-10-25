#!!/usr/bin/env bash

set -euo pipefail

rsync -avu --exclude='/ufo/.git/' /home/una/piland/proj-tmpl ~/gitdir/configs/pi-dirs/
rsync -avu --exclude='/ufo/.git/' /home/una/piland/ufo ~/gitdir/configs/pi-dirs/
