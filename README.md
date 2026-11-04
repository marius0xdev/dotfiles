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

The script installs Homebrew if necessary (with an interactive confirmation), installs packages with Homebrew Bundle, and links the Ghostty configuration using GNU Stow. It can be run repeatedly and will not overwrite conflicting existing configuration files.

**Initial scope:** Ghostty, JetBrainsMono Nerd Font, Catppuccin Mocha, GNU Stow, and Bash 5 installed alongside the macOS system Bash. The login shell remains unchanged. A window manager, Neovim, tmux, mise, and Omarchy integration are future additions.

## Repository layout

```text
Brewfile
bootstrap.sh
docs/macos-setup.md
ghostty/.config/ghostty/config
```

## Safety

- Read the bootstrap and Brewfile before running them.
- Never commit private SSH keys, access tokens, passwords, or recovery codes.
- Use one SSH key per machine.
- The Homebrew installer is downloaded from a pinned official Git commit to a temporary file, not piped directly to a shell. Review it before accepting execution. **A fixed SHA-256 checksum is not yet verified.**
- The bootstrap does not change macOS System Integrity Protection (SIP).
- Stow checks for conflicts and stops instead of overwriting existing dotfiles.

## License

MIT. See [LICENSE](LICENSE).
