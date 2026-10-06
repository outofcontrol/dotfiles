#!/usr/bin/env zsh

echo 'Update submodules'
echo '-----------------'
git submodule update --init --recursive

echo "Install xcode-select"
echo '--------------------'
sudo xcode-select --install > /dev/null 2>&1

echo 'Install homebrew'
echo '----------------'
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
brew analytics off

# Install zsh-patina - new syntax highlight
brew install zsh-patina

brew install atuin

echo 'Install all the brew stuff'
echo '=========================='

echo 'Install some nice quicklook plugins'
echo '-----------------------------------'
brew install --cask qlmarkdown quicklook-json suspicious-package

echo 'Install vim'
echo '-----------'
brew install vim

echo 'Install tree'
echo '------------'
brew install tree

echo 'Install pkg-config'
echo '------------------'
brew install pkg-config

echo 'Install wget'
echo '------------'
brew install wget

echo 'Install httpie'
echo '--------------'
brew install httpie

echo 'Install ncdu'
echo '------------'
brew install ncdu

echo 'Install gh (GitHub CLI)'
echo '-----------------------'
brew install gh

echo 'Install ack'
echo '-----------'
brew install ack

echo 'Install doctl'
echo '-------------'
brew install doctl

brew install jq

brew install sqlmap

brew install rsync

brew install s3cmd

echo 'Install zsh-autosuggestions, syntax-highlighting and completions'
echo '---------------------------'
brew install zsh-autosuggestions
brew install zsh-completions
brew install zsh-vi-mode

echo 'Install Fira Code Font'
echo '----------------------'
brew install --cask font-fira-code

echo 'Install ansible'
echo '---------------'
brew install ansible

echo 'Install awscli'
echo '--------------'
brew install awscli

brew install curl

brew cleanup

brew install pure

brew install fnm

echo 'Install container tooling (podman itself comes with Lerd, see misc-defaults.sh)'
echo '--------------------------------------------------------------------------------'
brew install --cask orbstack podman-desktop

echo 'Install OpenTofu'
echo '-----------------'
brew install opentofu

echo 'Install security and network tools'
echo '----------------------------------'
brew install gitleaks gnupg nmap mtr hcloud

echo 'Install media and document tools'
echo '--------------------------------'
brew install pandoc imagemagick ffmpeg exiftool pipx

echo 'Install GNU userland (Linux compatible ls, find, sed, grep, awk, tar)'
echo '----------------------------------------------------------------------'
brew install coreutils findutils gnu-sed grep gawk gnu-tar

echo 'Install misc CLI tools'
echo '----------------------'
brew install git uv reuse

echo 'Install apps'
echo '------------'
brew install --cask brave-browser iterm2 utm claude-code bruno dbeaver-community
brew install --cask signal vivaldi claude 1password nextcloud keyboard-maestro obsidian
brew install --cask phpstorm ray slack helo transmit
brew install --cask tor-browser zotero reunion firefox moom

echo 'Install Mac App Store apps (requires being signed in to the App Store)'
echo '-----------------------------------------------------------------------'
brew install mas
mas install 603637384   # Name Mangler 3
mas install 6444915884  # Ice Cubes for Mastodon
mas install 904280696   # Things 3
mas install 6504861501  # Ghostery AdBlocker for Privacy (Safari)
mas install 6720708363  # Obsidian Web Clipper (Safari)
mas install 497799835   # Xcode (large download, several GB)

echo 'Install Zed (official installer, not available as a cask we trust)'
echo '----------------------------------------------------------------------'
if [[ ! -d /Applications/Zed.app ]]; then
  curl -f https://zed.dev/install.sh | sh
fi

echo 'Install MailMate (latest build from the archive, newer than the brew cask)'
echo '---------------------------------------------------------------------------'
if [[ ! -d /Applications/MailMate.app ]]; then
  MAILMATE_BUILD=$(curl -fsSL "https://updates.mailmate-app.com/sub/archives/?C=M;O=D" | grep -o 'MailMate_r[0-9]*\.tbz' | head -1)
  if [[ -n "$MAILMATE_BUILD" ]]; then
    curl -fsSL -o "/tmp/$MAILMATE_BUILD" "https://updates.mailmate-app.com/sub/archives/$MAILMATE_BUILD"
    tar -xjf "/tmp/$MAILMATE_BUILD" -C /Applications
    rm -f "/tmp/$MAILMATE_BUILD"
  else
    echo 'Could not determine the latest MailMate build, skipping'
  fi
fi

echo '++++++++++++++++++++++++++++++'
echo 'All done!'
echo 'Put your custom aliases, exports and functions in .dotfiles-custom/shell'
echo '++++++++++++++++++++++++++++++'
