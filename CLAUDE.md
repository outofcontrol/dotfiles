# CLAUDE.md

## What this is

Personal macOS dotfiles repository. This is a collection of shell config, vim config, git config, and setup scripts that get symlinked into `$HOME`.

## Installation flow

Two entry points, both interactive (they prompt with `read -p` for confirmation before doing anything):

- `./bootstrap` — asks for confirmation, then `sudo -v` and sources `installscript`.
- `installscript` — asks separately whether to create symlinks, create directories, set up Homebrew, and/or run macOS defaults scripts. Each step is independently opt-in. Directories are created before symlinks so that `~/.config` and `~/.zsh` exist when links are made.

Symlink targets (`mkLink` in `installscript`) map repo paths into `$HOME`:

| Repo path         | Symlinked to     |
| ----------------- | ---------------- |
| `shell/vim`       | `~/.vim`         |
| `shell/vimrc`     | `~/.vimrc`       |
| `shell/zshrc`     | `~/.zshrc`       |
| `config/git`      | `~/.config/git`  |
| `shell/zprofile`  | `~/.zprofile`    |
| `shell/ideavimrc` | `~/.ideavimrc`   |
| `shell/hushlogin` | `~/.hushlogin`   |
| `config/zed/{settings,keymap,tasks}.json` | `~/.config/zed/<file>` (one link per file) |
| `config/atuin/config.toml` | `~/.config/atuin/config.toml` |
| `~/.dotfiles-custom/claude/settings.json` | `~/.claude/settings.json` |
| `~/.dotfiles-custom/claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `~/.dotfiles-custom/claude/statusline.sh` | `~/.claude/statusline.sh` |
| `~/.dotfiles-custom/claude/skills/<name>` | `~/.claude/skills/<name>` (one link per skill) |
| `~/.dotfiles-custom/claude/commands/<name>.md` | `~/.claude/commands/<name>.md` (one link per command) |
| `~/.dotfiles-custom/claude/agents/<name>.md` | `~/.claude/agents/<name>.md` (one link per agent) |

`mkLink` refuses to overwrite a real (non-symlink) file or directory that already exists at the destination, but will happily replace an existing symlink.

Setup scripts (only run if the user opts in):

- `setup/brew-defaults.sh` — installs Homebrew and a long list of CLI tools/casks (vim, wget, httpie, gh, sqlmap, awscli, ansible, doctl, atuin, pure prompt, fnm, zsh-vi-mode, orbstack, podman-desktop, iterm2, brave, etc).
- `setup/macos-defaults.sh` — sets macOS system defaults (computer name and timezone are prompted for, UI/UX prefs, based on Mathias Bynens' / Freek Van der Herten's dotfiles). Also enables Remote Login (SSH) restricted to key auth and the current user, but only if `~/.dotfiles-custom/ssh/authorized_keys` holds at least one public key; those keys are appended to `~/.ssh/authorized_keys` and the sshd restrictions go in `/etc/ssh/sshd_config.d/010-dotfiles.conf`.
- `setup/misc-defaults.sh` — sets up Docker/Podman zsh completions, fetches oh-my-zsh's `git.plugin.zsh` standalone (no full oh-my-zsh framework), installs the iTerm2 profile from `config/iterm/OOC.json` as a dynamic profile, and runs the Lerd installer if `lerd` is missing.
- `setup/sync-from-machine.sh` — the reverse direction. Pulls live state back into the repos: Zed's installed extensions into the `auto_install_extensions` block of `config/zed/settings.json`, the iTerm "OOC" profile into `config/iterm/OOC.json`, and the MCP servers from `~/.claude.json` into `~/.dotfiles-custom/claude/mcp.json`. Run it after changing any of those on the live machine, then review and commit both repos.
- `setup/claude-defaults.sh` — registers the user-scoped MCP servers declared in `~/.dotfiles-custom/claude/mcp.json` via `claude mcp add-json`, skipping any that already exist.

## Claude Code config

`~/.dotfiles-custom/claude/` holds the portable parts of the global Claude Code config. `~/.claude` itself is never symlinked because it also holds runtime state (sessions, caches, `plugins/`, `skills/synced/`), and `~/.claude.json` is never tracked because it mixes account identifiers, per-project history and caches with the one thing we want from it (`mcpServers`).

- `~/.dotfiles-custom/claude/settings.json` — permissions, sandbox, model, status line, enabled plugins. Paths use `~`, not an absolute home. The podman socket under `/var/folders/...` is machine-specific and will need editing on a new Mac.
- `~/.dotfiles-custom/claude/CLAUDE.md` — global user instructions.
- `~/.dotfiles-custom/claude/skills/` — only skills authored or vendored here. Claude's own `skills/synced/` is deliberately left out.
- `~/.dotfiles-custom/claude/commands/` — custom slash commands.
- `~/.dotfiles-custom/claude/agents/` — custom subagents, one Markdown file per agent.
- `~/.dotfiles-custom/claude/mcp.json` — MCP servers to register. Edit this and re-run `setup/claude-defaults.sh` rather than editing `~/.claude.json` by hand. Removing a server here does not unregister it (use `claude mcp remove`).

Adding a new skill, command or agent means dropping it into the matching directory under `~/.dotfiles-custom/claude/` and re-running the symlink step (or linking it by hand); `mkClaudeLinks` links whatever is present and skips directories that are empty.

## Shell config structure

`shell/zshrc` is the real `.zshrc` and is intentionally ordered:

1. Base env vars, PATH (built from `brew --prefix`; keg-only curl and the GNU `gnubin` directories are prepended so GNU ls/find/sed/grep/awk/tar shadow the BSD ones), phpbrew.
2. Completion system (`fpath` before `compinit`).
3. `pure` prompt.
4. SSH agent (keychain-backed).
5. Sources `~/.zsh/git.plugin.zsh`, then this repo's `shell/{exports,aliases,functions}`, then an optional `~/.dotfiles-custom/shell/{exports,aliases,functions,zshrc}` for machine-local/private overrides not tracked in git.
6. zsh plugins (autosuggestions, vi-mode).
7. Tool integrations (fnm, atuin).
8. `zsh-patina` activation — **must stay last** in the file.

`~/.dotfiles-custom/` where anything private/machine-specific that shouldn't live in this public repo. When adding personal secrets, machine-specific aliases, etc., they belong there, not in `shell/aliases` or `shell/exports`.

PHP, Composer, Node (via fnm) and databases come from Lerd (installed by `misc-defaults.sh`), not Homebrew. `shell/functions` includes Laravel/PHP-oriented helpers (`p`/`pf` run pest if present, else phpunit; `tinker`; `db`/`opendb` for reading Laravel's `.env` DB credentials; `scheduler` loops `php artisan schedule:run`).

## Git config

`config/git/config` is symlinked to `~/.config/git/config` and is the canonical gitconfig: user identity, many aliases (`co`, `st`, `lg`, `poh`, etc.), `pull.rebase=false`, `push.autoSetupRemote=true`, `init.defaultBranch=main`. `config/git/ignore` is the global excludesfile equivalent, referenced from this same config.

## Vim

`shell/vimrc` is a fairly minimal classic vimrc. Plugins are managed via Vundle (`shell/vim/plugins.vim`, git submodule at `shell/vim/bundle/Vundle.vim`). The submodule must be initialized (`git submodule update --init --recursive`, also done automatically by `brew-defaults.sh`), then `misc-defaults.sh` runs `vim +PluginInstall +qall` to fetch the rest into `shell/vim/bundle/`, which is gitignored. `vimrc` sources `plugins.vim` first, before anything else.

## Zed

`config/zed/` holds Zed's `settings.json`, `keymap.json` and `tasks.json`, linked file by file because Zed keeps a prompt database in the same directory. Extensions are not tracked as files. Zed installs whatever is listed under `auto_install_extensions` on launch, and `sync-from-machine.sh` regenerates that list from the extensions actually installed. `settings.json` is JSONC (comments allowed), so edit it with a text editor, not `jq`.

## iTerm2

`config/iterm/OOC.json` is the exported "OOC" profile (Fira Code 15, inline colours). `misc-defaults.sh` copies it into iTerm's DynamicProfiles folder. To update it, export the profile again from iTerm (Profiles, Other Actions, Save Profile as JSON) and overwrite the file; do not hand-edit the GUID.

## Making changes

- This repo is meant to be safe to re-run: setup scripts are idempotent-ish (checked with `command -v` / file-existence guards) but not fully so — read before re-running `brew-defaults.sh` or `macos-defaults.sh`, since they contain `sudo` calls and system-level changes (computer name, `defaults write`, service installs).
- Keep secrets and machine-specific config out of tracked files; use `~/.dotfiles-custom/` instead.
- GNU coreutils/findutils/sed/grep/awk/tar shadow the BSD tools once `zshrc` is loaded, so `shell/aliases` and `shell/functions` may use GNU syntax. `bootstrap`, `installscript` and everything in `setup/` run on a fresh Mac before that, with only Apple's BSD tools, so they must stick to flags both implementations accept (no `sed -i ''` vs `sed -i`, no `readlink -f`, no `date -v`).
- There is no test suite or CI; validate shell changes by sourcing them (`source shell/zshrc` or `zsh -n <file>` for a syntax check) rather than assuming correctness.
