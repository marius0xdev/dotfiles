# dotfiles

A reproducible, keyboard-first development environment for macOS. Omarchy support is planned.

## macOS quick start

Complete the one-time steps in [docs/macos-setup.md](docs/macos-setup.md), then:

```sh
cd ~/Code/dotfiles
git pull --ff-only
less bootstrap.sh
cat Brewfile
bash ./bootstrap.sh
```

The script installs Homebrew if necessary (with an interactive confirmation), installs packages with Homebrew Bundle, links the Ghostty, Amethyst, mise, tmux, Neovim, lazygit, Starship and zsh configurations using GNU Stow, and installs CLI tools (gh, lazygit, tmux, Starship, Neovim, ripgrep, fd, fzf, tree-sitter) with mise. It can be run repeatedly and will not overwrite conflicting existing configuration files.

**Current scope:** Ghostty, JetBrainsMono Nerd Font, Catppuccin Mocha, GNU Stow, Bash 5 (alongside the macOS system Bash), Amethyst, mise-managed CLI tools (gh, lazygit, tmux, Neovim and LazyVim's helpers), plus Omarchy-style tmux, LazyVim and Starship configurations. CLI tools come from mise where possible and from Homebrew only as a fallback. The login shell remains unchanged. Omarchy (Arch Linux) support is a future addition.

## Manual macOS settings

Some preferences have no supported command-line setting and are set by hand once per Mac:

- **Display scaling:** System Settings > Displays > select the built-in display > **More Space**. The resolution shown (e.g. `1800 × 1169`) depends on the Mac model.

## Repository layout

```text
Brewfile
amethyst/.amethyst.yml
bootstrap.sh
docs/macos-setup.md
ghostty/.config/ghostty/config
lazygit/Library/Application Support/lazygit/config.yml
macos/LaunchAgents/com.marius0xdev.capslock-escape.plist
mise/.config/mise/config.toml
nvim/.config/nvim/
starship/.config/starship.toml
tmux/.config/tmux/tmux.conf
zsh/.config/zsh/dotfiles.zsh
```

## Safety

- Read the bootstrap and Brewfile before running them.
- Never commit private SSH keys, access tokens, passwords, or recovery codes.
- Use one SSH key per machine.
- The Homebrew installer is downloaded from a pinned official Git commit to a temporary file, not piped directly to a shell. Review it before accepting execution. The downloaded installer is verified against a pinned SHA-256 digest before execution.
- The bootstrap does not change macOS System Integrity Protection (SIP).
- Stow checks for conflicts and stops instead of overwriting existing dotfiles.

## License

MIT. See [LICENSE](LICENSE).
