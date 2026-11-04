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
  printf '%s\n' "Homebrew is missing. Downloading the official installer for review."
  installer="$(mktemp "${TMPDIR:-/tmp}/homebrew-install.XXXXXX")"
  trap 'rm -f "$installer"' EXIT
  curl --fail --location --silent --show-error \
    --output "$installer" \
    https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
  printf 'Downloaded installer: %s\n' "$installer"
  printf '%s\n' "The installer is not pinned or checksum-verified. Review it before continuing."
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

# Dry-run first. Stow aborts on conflicts instead of overwriting user files.
mkdir -p "$HOME/.config"
stow --dir="$ROOT" --target="$HOME" --simulate --verbose=1 ghostty
stow --dir="$ROOT" --target="$HOME" ghostty

printf '\n%s\n' "Bootstrap complete. Open Ghostty to see the configured theme."
