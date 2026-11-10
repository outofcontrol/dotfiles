#!/usr/bin/env zsh

. "$HOME/.dotfiles/setup/lib.sh"

echo 'Update submodules'
echo '-----------------'
try git submodule update --init --recursive

echo "Install xcode-select"
echo '--------------------'
sudo xcode-select --install > /dev/null 2>&1

echo 'Install homebrew'
echo '----------------'
if ! command -v brew >/dev/null 2>&1; then
  try /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if [[ ! -x /opt/homebrew/bin/brew ]]; then
  echo 'Homebrew did not install, nothing else in this script can run.' >&2
  echo "$SETUP_SCRIPT: Homebrew install" >> "$DOTFILES_FAILURES"
  exit 1
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew analytics off

# Install zsh-patina - new syntax highlight
try brew install zsh-patina

try brew install atuin

echo 'Install all the brew stuff'
echo '=========================='

echo 'Install some nice quicklook plugins'
echo '-----------------------------------'
try brew install --cask qlmarkdown quicklook-json suspicious-package

echo 'Install vim'
echo '-----------'
try brew install vim

echo 'Install tree'
echo '------------'
try brew install tree

echo 'Install pkg-config'
echo '------------------'
try brew install pkg-config

echo 'Install wget'
echo '------------'
try brew install wget

echo 'Install httpie'
echo '--------------'
try brew install httpie

echo 'Install ncdu'
echo '------------'
try brew install ncdu

echo 'Install gh (GitHub CLI)'
echo '-----------------------'
try brew install gh

echo 'Install ack'
echo '-----------'
try brew install ack

echo 'Install doctl'
echo '-------------'
try brew install doctl

try brew install jq

try brew install sqlmap

try brew install rsync

try brew install s3cmd

echo 'Install zsh-autosuggestions, syntax-highlighting and completions'
echo '---------------------------'
try brew install zsh-autosuggestions
try brew install zsh-completions
try brew install zsh-vi-mode

echo 'Install Fira Code Font'
echo '----------------------'
try brew install --cask font-fira-code

echo 'Install ansible'
echo '---------------'
try brew install ansible

echo 'Install awscli'
echo '--------------'
try brew install awscli

try brew install curl

brew cleanup

try brew install pure

try brew install fnm

echo 'Install container tooling (podman itself comes with Lerd, see misc-defaults.sh)'
echo '--------------------------------------------------------------------------------'
try brew install --cask orbstack podman-desktop

echo 'Install OpenTofu'
echo '-----------------'
try brew install opentofu

echo 'Install security and network tools'
echo '----------------------------------'
try brew install gitleaks gnupg nmap mtr hcloud

echo 'Install media and document tools'
echo '--------------------------------'
try brew install pandoc imagemagick ffmpeg exiftool pipx

echo 'Install GNU userland (Linux compatible ls, find, sed, grep, awk, tar)'
echo '----------------------------------------------------------------------'
try brew install coreutils findutils gnu-sed grep gawk gnu-tar

echo 'Install misc CLI tools'
echo '----------------------'
try brew install git uv reuse

echo 'Install apps'
echo '------------'
try brew install --cask brave-browser iterm2 utm claude-code bruno dbeaver-community
try brew install --cask signal vivaldi claude 1password nextcloud keyboard-maestro obsidian
try brew install --cask phpstorm ray slack helo transmit
try brew install --cask tor-browser zotero reunion firefox moom

echo 'Install Mac App Store apps (requires being signed in to the App Store)'
echo '-----------------------------------------------------------------------'
try brew install mas
try mas install 603637384   # Name Mangler 3
try mas install 6444915884  # Ice Cubes for Mastodon
try mas install 904280696   # Things 3
try mas install 6504861501  # Ghostery AdBlocker for Privacy (Safari)
try mas install 6720708363  # Obsidian Web Clipper (Safari)
try mas install 497799835   # Xcode (large download, several GB)

# Once full Xcode is present, brew and the toolchain refuse to run until its
# license is accepted and the first-launch components are installed.
if [[ -d /Applications/Xcode.app ]]; then
  try sudo xcodebuild -license accept
  try sudo xcodebuild -runFirstLaunch
fi

echo 'Install Zed (official installer, not available as a cask we trust)'
echo '----------------------------------------------------------------------'
if [[ ! -d /Applications/Zed.app ]]; then
  try sh -c 'curl -f https://zed.dev/install.sh | sh'
fi
check 'Zed.app in /Applications' test -d /Applications/Zed.app

echo 'Install MailMate (latest build from the archive, newer than the brew cask)'
echo '---------------------------------------------------------------------------'
if [[ ! -d /Applications/MailMate.app ]]; then
  MAILMATE_BUILD=$(curl -fsSL "https://updates.mailmate-app.com/sub/archives/?C=M;O=D" | grep -o 'MailMate_r[0-9]*\.tbz' | head -1)
  if [[ -n "$MAILMATE_BUILD" ]]; then
    try curl -fsSL -o "/tmp/$MAILMATE_BUILD" "https://updates.mailmate-app.com/sub/archives/$MAILMATE_BUILD"
    try tar -xjf "/tmp/$MAILMATE_BUILD" -C /Applications
    rm -f "/tmp/$MAILMATE_BUILD"
  else
    echo 'Could not determine the latest MailMate build' >&2
    echo "$SETUP_SCRIPT: MailMate download (could not determine latest build)" >> "$DOTFILES_FAILURES"
  fi
fi
check 'MailMate.app in /Applications' test -d /Applications/MailMate.app

echo '++++++++++++++++++++++++++++++'
echo 'brew-defaults.sh finished'
echo 'Put your custom aliases, exports and functions in .dotfiles-custom/shell'
echo '++++++++++++++++++++++++++++++'
