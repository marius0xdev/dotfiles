# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

macOS dotfiles (Omarchy/Arch support is planned, not implemented). There is no build or test suite; `bootstrap.sh` is the single entry point and is meant to be re-runnable.

## Commands

```sh
bash ./bootstrap.sh                                   # full setup: Homebrew, brew bundle, stow, mise install
bash -n bootstrap.sh                                  # syntax check the bootstrap
brew bundle check --file=Brewfile                     # are all Brewfile entries installed?
stow --dir=. --target="$HOME" --simulate --verbose=1 <package>   # dry-run linking one package
```

## Architecture

- **Tool installation split:** CLI tools go in `mise/.config/mise/config.toml` (installed by `mise install`); the **Brewfile** holds mise itself, GUI casks, and only CLI tools mise can't provide (check `mise registry <tool>` first). mise versions are pinned exactly, never `latest`: reliability over freshness. Each Brewfile entry has a comment explaining why it's there.
- **Stow packages**: each top-level directory other than `docs/` (e.g. `ghostty/`, `amethyst/`) mirrors paths relative to `$HOME`. `ghostty/.config/ghostty/config` → `~/.config/ghostty/config`; `amethyst/.amethyst.yml` → `~/.amethyst.yml`. A new package must be added to **both** `stow` lines at the end of `bootstrap.sh` (the `--simulate` dry run and the real run). Whether `bootstrap.sh` pre-creates the target dir matters: pre-created (`~/.config/mise`) → Stow links individual files; not pre-created (`~/.config/nvim`) → the whole dir is a symlink, so files the app writes (`lazy-lock.json`, `lazyvim.json`) land in the repo and should be committed.
- **tmux/nvim** follow Omarchy (tmux.conf adapted from Omarchy; nvim = LazyVim starter + `lua/plugins/omarchy.lua`). Plugin versions are pinned by the committed `lazy-lock.json`.
- **bootstrap.sh** order: require macOS + Command Line Tools → find or install Homebrew → persist `brew shellenv` in `~/.zprofile` (idempotently) → `brew bundle` → persist `mise activate zsh --shims` in `~/.zprofile` (after Homebrew, so mise tools win) → stow dry run → stow → `mise install`.
- `gh` is mise-managed; Git's HTTPS credential helper must point at the stable shim `~/.local/share/mise/shims/gh`, not a versioned install path (see `docs/macos-setup.md`).
- **docs/macos-setup.md** holds manual steps that are deliberately not automated (SSH key, Git identity, Accessibility permission, Mission Control/Spaces setup). Keep it, the README and its "Repository layout" block in sync with changes.

## Conventions and constraints

- `bootstrap.sh` must stay compatible with macOS system Bash 3.2 (no associative arrays, `mapfile`, `${var,,}`, etc.) and runs with `set -euo pipefail`.
- The Homebrew installer is pinned to a commit **and** a SHA-256; update both together, only after independent verification. Never switch to piping a remote script to a shell.
- Never overwrite existing user config: rely on Stow's conflict detection rather than `--adopt`/forcing.
- Don't change the login shell, disable SIP, or add private-API window-management tools. Amethyst tiles windows on native macOS Spaces; Space creation and app-to-Space assignment stay manual.
- Amethyst keys in `~/.amethyst.yml` override its Preferences UI; Amethyst must be restarted to pick up changes.
- Repo Git identity is `marius0xdev <marius0x@gmail.com>` (set locally, not globally); the remote is reached via the `github-marius0xdev` SSH host alias.
- Docs must not claim a feature works until it is tested.
- Keyboard: macOS Spaces use `Command + 1..9`; tmux and Neovim use `Option` as Alt (left Option only, via Ghostty); Amethyst uses `Option + Shift` and `Control + Option + Shift`. Check new bindings against these.
