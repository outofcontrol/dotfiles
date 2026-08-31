# CLAUDE.md

## What this is

Personal macOS dotfiles repository. This is a collection of shell config, vim config, git config, and setup scripts that get symlinked into `$HOME`.

## Installation flow

Two entry points, both interactive (they prompt with `read -p` for confirmation before doing anything):

- `./bootstrap` — asks for confirmation, then `sudo -v` and sources `installscript`.
- `installscript` — asks separately whether to create symlinks, create directories, set up Homebrew, and/or run macOS defaults scripts. Each step is independently opt-in.

Symlink targets (`mkLink` in `installscript`) map repo paths into `$HOME`:

| Repo path                                 | Symlinked to                            |
| ----------------------------------------- | --------------------------------------- |
| `shell/bin`                               | `~/bin`                                 |
| `shell/vim`                               | `~/.vim`                                |
| `shell/vimrc`                             | `~/.vimrc`                              |
| `shell/zshrc`                             | `~/.zshrc`                              |
| `config/git`                              | `~/.config/git`                         |
| `shell/zprofile`                          | `~/.zprofile`                           |
| `shell/ideavimrc`                         | `~/.ideavimrc`                          |
| `shell/hushlogin`                         | `~/.hushlogin`                          |
| `misc/oh-my-zsh-custom/cobalt2.zsh-theme` | `~/.oh-my-zsh/themes/cobalt2.zsh-theme` |

`mkLink` refuses to overwrite a real (non-symlink) file that already exists at the destination, but will happily replace an existing symlink.

Setup scripts (only run if the user opts in):

- `setup/brew-defaults.sh` — installs Homebrew, PHP (8.3/8.4/8.5, links 8.4), Composer, Laravel Valet, and a long list of CLI tools/casks (vim, node, wget, httpie, sqlmap, awscli, ansible, doctl, atuin, pure prompt, fnm, zsh-vi-mode, etc).
- `setup/macos-defaults.sh` — sets macOS system defaults (computer name, timezone, UI/UX prefs, ~460 lines, based on Mathias Bynens' / Freek Van der Herten's dotfiles).
- `setup/misc-defaults.sh` — sets up Docker zsh completions and fetches oh-my-zsh's `git.plugin.zsh` standalone (no full oh-my-zsh framework).

## Shell config structure

`shell/zshrc` is the real `.zshrc` and is intentionally ordered:

1. Base env vars, PATH (built from `brew --prefix`), phpbrew.
2. Completion system (`fpath` before `compinit`).
3. `pure` prompt.
4. SSH agent (keychain-backed).
5. Sources `~/.zsh/git.plugin.zsh`, then this repo's `shell/{exports,aliases,functions}`, then an optional `~/.dotfiles-custom/shell/{exports,aliases,functions,zshrc}` for machine-local/private overrides not tracked in git.
6. zsh plugins (autosuggestions, vi-mode).
7. Tool integrations (fnm, atuin).
8. `zsh-patina` activation — **must stay last** in the file.

`~/.dotfiles-custom/` where anything private/machine-specific that shouldn't live in this public repo. When adding personal secrets, machine-specific aliases, etc., they belong there, not in `shell/aliases` or `shell/exports`.

`shell/functions` includes Laravel/PHP-oriented helpers (`p`/`pf` run pest if present, else phpunit; `tinker`; `xdebug` toggle; `db`/`opendb` for reading Laravel's `.env` DB credentials; `scheduler` loops `php artisan schedule:run`).

## Git config

`config/git/config` is symlinked to `~/.config/git/config` and is the canonical gitconfig: user identity, many aliases (`co`, `st`, `lg`, `poh`, etc.), `pull.rebase=false`, `push.autoSetupRemote=true`, `init.defaultBranch=main`. `config/git/ignore` is the global excludesfile equivalent, referenced from this same config.

## Vim

`shell/vimrc` is a fairly minimal classic vimrc. Plugins are managed via Vundle (`shell/vim/plugins.vim`, git submodule at `shell/vim/bundle/Vundle.vim`), plus two vendored plugin submodules (`ctrlp.vim`, `nerdtree`) declared in `.gitmodules`. Submodules must be initialized (`git submodule update --init --recursive`, also done automatically by `brew-defaults.sh`) before vim plugins will work.

## Making changes

- This repo is meant to be safe to re-run: setup scripts are idempotent-ish (checked with `command -v` / file-existence guards) but not fully so — read before re-running `brew-defaults.sh` or `macos-defaults.sh`, since they contain `sudo` calls and system-level changes (computer name, `defaults write`, service installs).
- Keep secrets and machine-specific config out of tracked files; use `~/.dotfiles-custom/` instead.
- There is no test suite or CI; validate shell changes by sourcing them (`source shell/zshrc` or `zsh -n <file>` for a syntax check) rather than assuming correctness.
