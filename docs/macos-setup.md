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

The script downloads a commit-pinned Homebrew installer if missing (with SHA-256 verification), runs `brew bundle` including Claude Code and mise, links the Ghostty, Amethyst and mise configurations using GNU Stow, and runs `mise install` for the CLI tools in `~/.config/mise/config.toml` (gh, lazygit, tmux). It also adds mise's shims to `PATH` in `~/.zprofile`; open a new terminal afterwards. If Ghostty already has a configuration, resolve the conflict manually rather than overwriting it.

### CLI tools: mise first, Homebrew as fallback

CLI tools are installed by mise (`mise/.config/mise/config.toml`); Homebrew installs mise itself, GUI apps (casks), and only those CLI tools mise can't provide. Add a tool with `mise use -g <tool>@latest` (Stow links the config into the repo, so the change shows up in `git diff`); check availability with `mise registry <tool>`.

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

## Recovery and backup

Use separate SSH keys on separate machines. If a Mac is lost, revoke that machine's key in GitHub and create a new key on the replacement machine. A private SSH key backup is optional; secure account recovery and 2FA recovery codes are more important. Never commit secrets or recovery codes.

## Planned work

- Refine Amethyst keyboard shortcuts and workspace assignments after validating the initial setup.
- Add tmux and lazygit configuration (both are installed via mise, with default settings for now).
- Consider pinning mise tool versions instead of `latest`.
- Add Neovim and cross-platform Stow packages.
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
- Our desired `Option + 1` ... `Option + 9` workspace-switching bindings are **not yet implemented**. Do not claim they work until a tested shortcut mechanism is added. macOS's native Control-number shortcuts are the initial fallback.
- Some shortcuts can conflict with typing special characters on Polish keyboard layouts; choose bindings after testing the physical keyboard.
- Do not disable SIP or install experimental private-API tools just to automate native Spaces.
- Amethyst's YAML configuration is linked via Stow to `~/.amethyst.yml`. It currently only hides the layout-name HUD (e.g. "Tall") shown on Space switches and layout changes; restart Amethyst after editing it. Keys in that file override the Preferences UI. Layout and shortcut settings can be added after verifying them in the app.
