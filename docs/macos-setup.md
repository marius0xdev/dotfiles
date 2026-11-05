# macOS setup

This document records the one-time manual steps required before running the dotfiles bootstrap.

## 1. GitHub identity

Create the GitHub account `marius0xdev` and the public `marius0xdev/dotfiles` repository with an MIT license.

**Security follow-up:** Enable two-factor authentication on GitHub, protect the Google sign-in account, and save GitHub recovery codes securely. This is still pending.

## 2. Apple Command Line Tools

A fresh Mac may offer to install the Apple Command Line Developer Tools when `git` is first invoked. Select **Install**. Alternatively:

```sh
xcode-select --install
```

Verify:

```sh
git --version
xcode-select -p
```

The developer directory normally resolves to `/Library/Developer/CommandLineTools`. Full Xcode is not necessary for this setup.

## 3. Generate a machine-specific SSH key

```sh
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t ed25519 -C "marius0x@gmail.com" -f ~/.ssh/id_ed25519_marius0xdev
```

Choose a passphrase. Never share or commit the private key. Copy the public key only:

```sh
pbcopy < ~/.ssh/id_ed25519_marius0xdev.pub
```

Add it as an **Authentication Key** at [GitHub SSH settings](https://github.com/settings/keys).

## 4. SSH alias

Append this block to `~/.ssh/config` without overwriting existing entries:

```sshconfig
Host github-marius0xdev
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_ed25519_marius0xdev
    IdentitiesOnly yes
    AddKeysToAgent yes
    UseKeychain yes
```

Then:

```sh
chmod 600 ~/.ssh/config
ssh -T git@github-marius0xdev
```

Before accepting GitHub's host key for the first time, verify its fingerprint using [GitHub's official published fingerprints](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints). GitHub may return exit status 1 even after successful SSH authentication because shell access is disabled.

## 5. Clone and set local Git identity

```sh
mkdir -p ~/Code
git clone git@github-marius0xdev:marius0xdev/dotfiles.git ~/Code/dotfiles
cd ~/Code/dotfiles
git config --local user.name "marius0xdev"
git config --local user.email "marius0x@gmail.com"
git remote -v
git status
```

If already cloned, do not clone again; use `cd ~/Code/dotfiles && git pull --ff-only`.

## 6. Bootstrap

Review the scripts first:

```sh
cd ~/Code/dotfiles
less bootstrap.sh
cat Brewfile
bash ./bootstrap.sh
```

The script downloads a commit-pinned Homebrew installer if missing (with SHA-256 verification), runs `brew bundle` including Claude Code and mise, links the Ghostty, Amethyst, mise, tmux, Neovim and lazygit configurations using GNU Stow, and runs `mise install` for the CLI tools in `~/.config/mise/config.toml` (gh, lazygit, tmux, Neovim and LazyVim's helpers: ripgrep, fd, fzf, tree-sitter). It also adds mise's shims to `PATH` in `~/.zprofile`; open a new terminal afterwards. If Ghostty already has a configuration, resolve the conflict manually rather than overwriting it.

### CLI tools: mise first, Homebrew as fallback

CLI tools are installed by mise (`mise/.config/mise/config.toml`); Homebrew installs mise itself, GUI apps (casks), and only those CLI tools mise can't provide. Versions are pinned exactly (never `latest`) so every machine gets the same, tested tools. Add a tool with an explicit version, e.g. `mise use -g lazygit@0.66.2` (Stow links the config into the repo, so the change shows up in `git diff`); check availability with `mise registry <tool>`.

### GitHub CLI authentication and Git credential helper

`gh` stores its token in the macOS Keychain. To push over HTTPS with it, point Git's credential helper at mise's **shim** (a stable path; `gh auth setup-git` would record a versioned install path that breaks when `gh` is upgraded):

```sh
gh auth login --hostname github.com --git-protocol https --with-token   # paste token, then Ctrl-D
for host in github.com gist.github.com; do
  git config --global --unset-all "credential.https://$host.helper"
  git config --global --add "credential.https://$host.helper" ''
  git config --global --add "credential.https://$host.helper" '!'"$HOME/.local/share/mise/shims/gh auth git-credential"
done
```

When migrating from a Homebrew-installed `gh`, run the loop above after `bash ./bootstrap.sh`, then `brew uninstall gh`, and check that `command -v gh` shows the mise shim in a new terminal.

Amethyst requires macOS Accessibility permission, which must be granted manually in System Settings after reviewing the request.

### tmux (Omarchy-style)

`tmux/.config/tmux/tmux.conf` is adapted from [Omarchy's tmux config](https://github.com/omacom/omarchy/blob/quattro/config/tmux/tmux.conf). Prefix is `Control + Space` (`Control + B` also works); `prefix ?` lists all bindings, `prefix q` reloads the config. Alt bindings use the **left Option** key (Ghostty's `macos-option-as-alt = left`; right Option still types Polish characters):

- `Option + Enter` / `Option + Shift + Enter`: split pane vertically / horizontally; `Option + Escape`: kill pane
- `Control + Option + arrows`: focus pane; `Control + Option + Shift + arrows`: resize pane
- `Option + 1..9`: switch window; `Option + Left/Right`: previous/next window; `Option + Up/Down`: previous/next session

Spaces are switched with `Command + 1..9`, so tmux's `Option + 1..9` doesn't clash with them. The resize keys share Amethyst's `Control + Option + Shift` modifier; whichever app grabs a key globally wins, so test them together before changing either side.

### lazygit

Installed via mise; `lazygit/Library/Application Support/lazygit/config.yml` (macOS's lazygit config path) only sets the Catppuccin Mocha theme; otherwise defaults, like Omarchy. Start it with `lazygit` in a repo, or `Space g g` inside LazyVim. lazygit creates an empty `config.yml` on its first run; if Stow reports a conflict for it, delete that empty file and rerun the bootstrap.

### Caps Lock as Escape

The bootstrap installs `macos/LaunchAgents/com.marius0xdev.capslock-escape.plist` into `~/Library/LaunchAgents` and loads it. It runs macOS's built-in `hidutil` at every login to remap Caps Lock to Escape on all keyboards (handy for leaving insert mode in Neovim); Caps Lock itself is then unavailable. No third-party app is needed.

- Check: `hidutil property --get UserKeyMapping` shows the mapping (`30064771129` → `30064771113`).
- Undo:
  ```sh
  launchctl bootout "gui/$(id -u)/com.marius0xdev.capslock-escape"
  rm ~/Library/LaunchAgents/com.marius0xdev.capslock-escape.plist
  hidutil property --set '{"UserKeyMapping":[]}'
  ```
- If **System Settings > Keyboard > Keyboard Shortcuts > Modifier Keys** also remaps Caps Lock, leave it at the default ("⇪ Caps Lock") to avoid two layers of remapping.

### Neovim (LazyVim, Omarchy-style)

`nvim/.config/nvim` is the [LazyVim starter](https://github.com/LazyVim/starter) plus Omarchy's tweaks ([omarchy-lazyvim](https://github.com/omacom/omarchy-lazyvim)): Neo-tree, no scroll animation, and Catppuccin Mocha to match Ghostty. The first `nvim` start downloads plugins and compiles treesitter parsers (needs network and the Command Line Tools' C compiler), then writes `nvim/.config/nvim/lazy-lock.json` into this repo: **commit it**, since it pins every plugin to an exact commit. Use `:Lazy restore` to install exactly the locked versions; `:Lazy update` deliberately bumps them (review the lockfile diff, then commit).

## Recovery and backup

Use separate SSH keys on separate machines. If a Mac is lost, revoke that machine's key in GitHub and create a new key on the replacement machine. A private SSH key backup is optional; secure account recovery and 2FA recovery codes are more important. Never commit secrets or recovery codes.

## Planned work

- Refine Amethyst keyboard shortcuts and workspace assignments after validating the initial setup.
- TODO: add Renovate so it opens PRs when new versions of pinned mise tools are released. Its `mise` manager should pick up `mise/.config/mise/config.toml`; verify the file pattern matches, and keep updates as reviewable PRs (no automerge). Consider its `lazy` manager for `lazy-lock.json` too.
- Add cross-platform Stow packages.
- Add Arch Linux / Omarchy support.

## 7. Amethyst and native macOS Spaces (manual setup)

The Brewfile installs **Amethyst**. It tiles windows on native macOS Spaces; it does **not** automatically create Spaces or assign Chrome and Slack to numbered desktops. Those steps remain manual and are intentionally documented here.

1. In **System Settings > Desktop & Dock > Mission Control**, turn off **Automatically rearrange Spaces based on most recent use**. This prevents macOS from changing the order of numbered desktops. Alternatively, after understanding the Dock restart: `defaults write com.apple.dock workspaces-auto-swoosh -bool NO && killall Dock`.
2. Open **Mission Control** with `Control + Up Arrow`, then use the **+** button at the top to create a total of **nine desktops**. If multiple displays are attached, check which display owns the Spaces.
3. Launch **Amethyst** from Applications/Spotlight. Grant **System Settings > Privacy & Security > Accessibility > Amethyst** permission so it can arrange windows. On a managed work Mac, follow IT policy for granting this permission.
4. In **System Settings > Keyboard > Keyboard Shortcuts > Mission Control**, enable **Switch to Desktop 1** through **Switch to Desktop 9**, if available. Assign the native macOS shortcuts there; test them before customizing further. macOS may not expose every shortcut until the corresponding desktop exists.
5. On **Desktop 1**, open Chrome, right-click its Dock icon and choose **Options > Assign To > This Desktop**. Repeat with Slack on **Desktop 7**. These assignments are native macOS preferences, not managed by Amethyst.
6. Test Amethyst by opening two ordinary windows on one desktop. Its default `Option + Shift + Space` cycles tiling layouts. Its default `Control + Option + Shift + [number]` can move the focused window to a numbered Space; check Amethyst's current Shortcuts preferences for the exact bindings.

### Known limitations and future keyboard work

- Amethyst controls **window tiling**; Mission Control/macOS controls **Space creation, switching and app assignment**.
- Spaces are switched with `Command + 1..9`, assigned in **System Settings > Keyboard > Keyboard Shortcuts > Mission Control**. macOS handles these before apps, so app shortcuts on `Command + number` (e.g. tab switching in Ghostty or Chrome) no longer fire.
- Some shortcuts can conflict with typing special characters on Polish keyboard layouts; choose bindings after testing the physical keyboard.
- Do not disable SIP or install experimental private-API tools just to automate native Spaces.
- Amethyst's YAML configuration is linked via Stow to `~/.amethyst.yml`. It currently only hides the layout-name HUD (e.g. "Tall") shown on Space switches and layout changes; restart Amethyst after editing it. Keys in that file override the Preferences UI. Layout and shortcut settings can be added after verifying them in the app.
