# My personal dotfiles

This repository contains the installation of some basic tools, some handy
aliases and functions, and some Claude configs.

## Install

Clone the repository as `.dotfiles` in your home directory and run the
bootstrap script. Use the HTTPS URL. A new Mac has no SSH keys yet, and git
will prompt for a GitHub login (or a personal access token) and store it in the
keychain.

```bash
cd ~
git clone https://github.com/outofcontrol/dotfiles.git .dotfiles
git clone https://github.com/outofcontrol/dotfiles-custom.git .dotfiles-custom
cd .dotfiles
./bootstrap
```

The second clone is my private overlay (git identity, private shell config,
private Claude config, SSH authorized keys). It is optional and only I can
clone it. If you are not me, skip that line or point it at your own private
repo with the same layout (`claude/`, `git/`, `shell/`, `ssh/`). Clone it
before running bootstrap so its files are linked in the same run.

`bootstrap` asks before each step: symlinks, directories, Homebrew, and the
macOS setup scripts. Answer `y` to all of them on a fresh machine.

### Before you run bootstrap

- Do not run it as root. It refuses, and asks for `sudo` itself when needed.
- Sign in to the Mac App Store first. Several apps, including Xcode, are
  installed with `mas`, which fails silently when nobody is signed in.
  bootstrap asks you to confirm this.
- Give your terminal app Full Disk Access (System Settings, Privacy and
  Security, Full Disk Access). Safari is sandboxed and its `defaults write`
  lines land in the wrong place without it.
- Quit iTerm2 if it is running. The setup makes the `OOC` profile the default,
  and a running iTerm overwrites that on its next preference save. Run bootstrap
  from Terminal.app.

### If something fails

Every install step is wrapped so a failure is recorded instead of aborting the
run. When the scripts finish, `installscript` prints the list of steps that
failed or left something missing, and exits non zero. The same list is in
`~/.dotfiles-install-failures.log`. Fix the item by hand, or re-run the single
script that owns it (`setup/brew-defaults.sh`, `setup/misc-defaults.sh`,
`setup/macos-defaults.sh`, `setup/claude-defaults.sh`). All of them are safe to
re-run.

After the run, open a new terminal tab so the new shell config, PATH and iTerm
profile take effect.

Feel free to create an issue on this repo if you have any questions. PRs accepted if they improve upon what I use.

## What gets installed

### Applications (Homebrew casks)

1Password, Brave Browser, Bruno, Claude, Claude Code, DBeaver Community,
Firefox, Fira Code font, HELO, iTerm2, Keyboard Maestro, Moom, Nextcloud,
Obsidian, OrbStack, PhpStorm, Podman Desktop, QLMarkdown, QuickLook JSON, Ray,
Reunion, Signal, Slack, Suspicious Package, Tor Browser, Transmit, UTM, Vivaldi,
Zotero

### Applications (Mac App Store)

Ghostery AdBlocker for Privacy, Ice Cubes for Mastodon, Name Mangler 3, Obsidian
Web Clipper, Things 3, Xcode

### Applications (vendor installers)

Lerd, MailMate, Zed

### Command line tools (Homebrew)

ack, ansible, atuin, awscli, curl, doctl, fnm, gh, git, gitleaks, gnupg, httpie,
jq, mas, mtr, ncdu, nmap, node, opentofu, pkg-config, pure, reuse, rsync, s3cmd,
sqlmap, tree, uv, vim, wget, yarn, zsh-autosuggestions, zsh-completions,
zsh-patina, zsh-vi-mode

## Special Thanks

This repository would not have become reality without the inspiration and hard
work of @freekmurze. Pretty much everything in this repository is cobbled
together from the following sources:

- https://github.com/freekmurze/dotfiles
- https://dotfiles.github.io/inspiration/
- https://github.com/Vaelatern/init-dotfiles
- https://www.anishathalye.com/2014/08/03/managing-your-dotfiles/
- https://github.com/anishathalye/dotbot
- https://wilsonmar.github.io/dotfiles/
- https://macos-defaults.com
- https://gist.github.com/gokure/3488458#file-gitconfig-L17
- https://git-scm.com/docs/git-config
