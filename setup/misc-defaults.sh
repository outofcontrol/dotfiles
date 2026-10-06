#!/bin/bash
set -Eeuo pipefail

# Generate zsh completions for tools that do not ship them via Homebrew.
# Each tool must support `<tool> completion zsh`.

COMPLETION_TOOLS=(docker podman)

mkdir -p "$HOME/.zsh/completions"

for tool in "${COMPLETION_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    "$tool" completion zsh > "$HOME/.zsh/completions/_$tool"
  fi
done

# Fetch the standalone git aliases file (gst, gco, gp...) sourced by shell/zshrc.
# It is hosted in the oh-my-zsh repo but is a single self-contained script;
# oh-my-zsh itself is not installed or used.

GIT_PLUGIN_FILE="$HOME/.zsh/git.plugin.zsh"

if [[ ! -f "$GIT_PLUGIN_FILE" ]]; then
  mkdir -p "$HOME/.zsh"
  curl -fsSL -o "$GIT_PLUGIN_FILE" \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh
fi

# Install vim plugins declared in shell/vim/plugins.vim (Vundle itself is a git submodule)

if [[ -f "$HOME/.vim/bundle/Vundle.vim/autoload/vundle.vim" ]]; then
  vim -es -u "$HOME/.vimrc" +PluginInstall +qall
fi

# Install the iTerm2 profile as a dynamic profile (iTerm picks it up on launch)

ITERM_PROFILES="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$ITERM_PROFILES"
cp "$HOME/.dotfiles/config/iterm/OOC.json" "$ITERM_PROFILES/OOC.json"

# Install Lerd (Podman based local PHP environment, not available via Homebrew)
# The installer appends PATH lines to ~/.zshrc; shell/zshrc already has them.

if ! command -v lerd >/dev/null 2>&1; then
  curl -fsSL https://lerd.sh/install.sh | bash
fi
