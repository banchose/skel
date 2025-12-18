#!/usr/bin/env bash

alias troll='terraform fmt && terraform validate && terraform plan && terraform apply'
alias rdockp='docker -H ssh://una@unit1 ps --all'
alias rdocki='docker -H ssh://una@unit1 images'
alias rdockc='docker -H ssh://una@unit1 container ls --all'
