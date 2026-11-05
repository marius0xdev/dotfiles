#!/usr/bin/env bash
# Initial macOS bootstrap; compatible with the system Bash 3.2.
set -euo pipefail

if [ "$(uname -s)" != "Darwin" ]; then
  printf '%s\n' "This bootstrap currently supports macOS only." >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")" && pwd)"

if ! xcode-select -p >/dev/null 2>&1; then
  printf '%s\n' "Install Apple Command Line Tools first: xcode-select --install" >&2
  exit 1
fi

# Discover Homebrew in standard Apple Silicon and Intel locations.
if ! command -v brew >/dev/null 2>&1; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if ! command -v brew >/dev/null 2>&1; then
  # Pin the official Homebrew installer to a Git commit and an expected SHA-256.
  # When updating, independently verify and change both values together.
  HOMEBREW_INSTALL_COMMIT="09c62fc577ec170172b0a184060f141a2c622dc1"
  HOMEBREW_INSTALL_SHA256="5f333bbe53bc490e51e7ccb1df8779b3dd6ee73a1a7379efda216edb08ccb148"
  HOMEBREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/$HOMEBREW_INSTALL_COMMIT/install.sh"

  printf '%s\n' "Homebrew is missing. Downloading a commit-pinned official installer."
  installer="$(mktemp "${TMPDIR:-/tmp}/homebrew-install.XXXXXX")"
  trap 'rm -f "$installer"' EXIT
  curl --fail --location --silent --show-error \
    --output "$installer" "$HOMEBREW_INSTALL_URL"
  # Never execute the installer unless its bytes match the pinned digest.
  actual_sha256="$(shasum -a 256 "$installer" | awk '{print $1}')"
  if [ "$actual_sha256" != "$HOMEBREW_INSTALL_SHA256" ]; then
    printf '%s\n' "ERROR: Homebrew installer SHA-256 mismatch. Aborting." >&2
    printf 'Expected: %s\nActual:   %s\n' "$HOMEBREW_INSTALL_SHA256" "$actual_sha256" >&2
    exit 1
  fi
  printf '%s\n' "Homebrew installer SHA-256 verified."
  printf 'Installer source: %s\n' "$HOMEBREW_INSTALL_URL"
  printf '%s\n' "Run the downloaded Homebrew installer? [y/N] "
  read -r answer
  case "$answer" in
    y|Y|yes|YES) /bin/bash "$installer" ;;
    *) printf '%s\n' "Cancelled."; exit 1 ;;
  esac
  rm -f "$installer"
  trap - EXIT
fi

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  brew_executable=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
  brew_executable=/usr/local/bin/brew
else
  printf '%s\n' "Homebrew was not found after installation." >&2
  exit 1
fi

# Persist Homebrew initialization for future macOS zsh login sessions.
shellenv_line="eval \"\$($brew_executable shellenv)\""
if ! grep -Fqx "$shellenv_line" "$HOME/.zprofile" 2>/dev/null; then
  printf '\n%s\n' '# Homebrew' "$shellenv_line" >> "$HOME/.zprofile"
fi

brew bundle --file="$ROOT/Brewfile"

# Put mise shims on PATH after Homebrew so mise-managed tools take precedence.
# Shims (not `mise activate` hooks) also work in non-interactive shells.
mise_executable="$(brew --prefix)/bin/mise"
mise_line="eval \"\$($mise_executable activate zsh --shims)\""
if ! grep -Fqx "$mise_line" "$HOME/.zprofile" 2>/dev/null; then
  printf '\n%s\n' '# mise' "$mise_line" >> "$HOME/.zprofile"
fi

# Dry-run first. Stow aborts on conflicts instead of overwriting user files.
# Pre-create ~/.config/mise so Stow links only config.toml, not the directory.
# ~/.config/nvim is deliberately not pre-created: Stow links the whole
# directory, so lazy.nvim writes lazy-lock.json into the repo for committing.
# Pre-create lazygit's macOS config dir so its state.yml stays out of the repo.
mkdir -p "$HOME/.config/mise" "$HOME/Library/Application Support/lazygit"
stow --dir="$ROOT" --target="$HOME" --simulate --verbose=1 ghostty amethyst mise tmux nvim lazygit
stow --dir="$ROOT" --target="$HOME" ghostty amethyst mise tmux nvim lazygit

# Install the tools declared in ~/.config/mise/config.toml.
"$mise_executable" install

printf '\n%s\n' "Bootstrap complete. Open a new Ghostty window so mise tools are on PATH."
