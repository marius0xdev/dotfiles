# GNU Stow creates symlinks from this repository into the home directory.
# This keeps application configuration version-controlled without copying files.
brew "stow"

# Install a modern Bash (5.x) for future scripts and interactive use.
# macOS /bin/bash stays untouched; the default login shell remains zsh.
brew "bash"

# mise installs and versions CLI tools (gh, lazygit, tmux, ...); see
# mise/.config/mise/config.toml. Prefer mise; use Homebrew only for tools
# mise can't provide, plus GUI apps (casks).
brew "mise"

# fzf-tab replaces zsh's Tab completion menu with fzf (fzf itself is from mise).
# It is a zsh plugin, not a binary, so mise has no registry entry for it.
brew "fzf-tab"

# Ghostty is the terminal emulator used on macOS.
cask "ghostty"

# Nerd Font provides programming ligatures and icons for terminal tools.
cask "font-jetbrains-mono-nerd-font"

# Claude Code is Anthropic's terminal-based AI coding assistant.
# The stable Homebrew cask is used instead of the latest release channel.
cask "claude-code"

# Amethyst automatically tiles windows within native macOS Spaces.
# Unlike AeroSpace, it does not replace macOS Spaces with virtual workspaces.
cask "amethyst"
