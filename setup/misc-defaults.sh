#!/bin/bash
set -Eeuo pipefail

# Setup auto complete for Docker

if command -v docker >/dev/null 2>&1; then
  mkdir -p "$HOME/.zsh/completions"
  docker completion zsh > "$HOME/.zsh/completions/_docker"
fi

# Fetch oh-my-zsh's git plugin (aliases only, sourced directly, no framework needed)

GIT_PLUGIN_FILE="$HOME/.zsh/git.plugin.zsh"

if [[ ! -f "$GIT_PLUGIN_FILE" ]]; then
  mkdir -p "$HOME/.zsh"
  curl -fsSL -o "$GIT_PLUGIN_FILE" \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh
fi
