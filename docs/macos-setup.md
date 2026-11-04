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

The script downloads a commit-pinned Homebrew installer if missing (with SHA-256 verification), runs `brew bundle` including Claude Code, and links Ghostty's configuration using GNU Stow. If Ghostty already has a configuration, resolve the conflict manually rather than overwriting it.

Amethyst requires macOS Accessibility permission, which must be granted manually in System Settings after reviewing the request.

## Recovery and backup

Use separate SSH keys on separate machines. If a Mac is lost, revoke that machine's key in GitHub and create a new key on the replacement machine. A private SSH key backup is optional; secure account recovery and 2FA recovery codes are more important. Never commit secrets or recovery codes.

## Planned work

- Refine Amethyst keyboard shortcuts and workspace assignments after validating the initial setup.
- Add tmux, mise, Neovim and cross-platform Stow packages.
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
- An Amethyst YAML configuration can be added via Stow later, after verifying the preferred layout and shortcut settings in the app.
