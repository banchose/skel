#!/usr/bin/env bash

set -xeuo pipefail

update-flatpak() {

  sudo flatpak upgrade
  sudo flatpak uninstall --unused

}
