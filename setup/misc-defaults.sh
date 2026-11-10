#!/bin/bash
set -Eeuo pipefail

. "$HOME/.dotfiles/setup/lib.sh"

# Homebrew is not on PATH yet in a fresh install shell; the Lerd installer needs it for podman.
if ! command -v brew >/dev/null 2>&1; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Fetch the standalone git aliases file (gst, gco, gp...) sourced by shell/zshrc.
# It is hosted in the oh-my-zsh repo but is a single self-contained script;
# oh-my-zsh itself is not installed or used.

GIT_PLUGIN_FILE="$HOME/.zsh/git.plugin.zsh"

if [[ ! -f "$GIT_PLUGIN_FILE" ]]; then
  mkdir -p "$HOME/.zsh"
  try curl -fsSL -o "$GIT_PLUGIN_FILE" \
    https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh
fi
check 'git.plugin.zsh downloaded' test -s "$GIT_PLUGIN_FILE"

# Link the Zed CLI. Zed ships it inside the app bundle but only installs it
# into PATH when asked from the GUI (Zed > Install CLI). ~/.local/bin is on
# PATH in shell/zshrc.

ZED_CLI=/Applications/Zed.app/Contents/MacOS/cli
if [[ -x "$ZED_CLI" && ! -e "$HOME/.local/bin/zed" ]]; then
  mkdir -p "$HOME/.local/bin"
  try ln -s "$ZED_CLI" "$HOME/.local/bin/zed"
fi
check 'zed CLI linked at ~/.local/bin/zed' test -x "$HOME/.local/bin/zed"

# Install vim plugins declared in shell/vim/plugins.vim (Vundle itself is a git submodule)

if [[ -f "$HOME/.vim/bundle/Vundle.vim/autoload/vundle.vim" ]]; then
  try vim -es -u "$HOME/.vimrc" +PluginInstall +qall
fi
check 'vim plugins installed in ~/.vim/bundle' test "$(ls "$HOME/.vim/bundle" | wc -l)" -gt 1

# Install the iTerm2 profile as a dynamic profile (iTerm picks it up on launch)

ITERM_PROFILES="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
mkdir -p "$ITERM_PROFILES"
try cp "$HOME/.dotfiles/config/iterm/OOC.json" "$ITERM_PROFILES/OOC.json"

# Make OOC the default profile so new windows use it. iTerm reads this on
# launch, so quit and reopen iTerm if it was running.
OOC_GUID=$(python3 -c 'import json,sys; print(json.load(open(sys.argv[1]))["Profiles"][0]["Guid"])' "$HOME/.dotfiles/config/iterm/OOC.json")
try defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$OOC_GUID"

# Install Lerd (Podman based local PHP environment, not available via Homebrew)
# The installer appends PATH lines to ~/.zshrc; shell/zshrc already has them.

if ! command -v lerd >/dev/null 2>&1; then
  try sh -c 'curl -fsSL https://lerd.sh/install.sh | bash'
fi
export PATH="$HOME/.local/bin:$HOME/.local/share/lerd/bin:$PATH"
check 'lerd on PATH' command -v lerd
check 'podman on PATH' command -v podman

# Generate zsh completions for tools that do not ship them via Homebrew.
# Each tool must support `<tool> completion zsh`. Runs after the Lerd install
# because Lerd provides podman.

COMPLETION_TOOLS=(docker podman)

mkdir -p "$HOME/.zsh/completions"

for tool in "${COMPLETION_TOOLS[@]}"; do
  if command -v "$tool" >/dev/null 2>&1; then
    try sh -c "$tool completion zsh > '$HOME/.zsh/completions/_$tool'"
  else
    check "$tool on PATH (completions skipped)" false
  fi
done
