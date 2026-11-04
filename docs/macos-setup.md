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

The script downloads a commit-pinned Homebrew installer if missing (without a fixed SHA-256 check yet), runs `brew bundle` including Claude Code, and links Ghostty's configuration using GNU Stow. If Ghostty already has a configuration, resolve the conflict manually rather than overwriting it.

Some future applications may require macOS Accessibility permissions, which must be granted in System Settings after reviewing the request. This initial version does not install a window manager.

## Recovery and backup

Use separate SSH keys on separate machines. If a Mac is lost, revoke that machine's key in GitHub and create a new key on the replacement machine. A private SSH key backup is optional; secure account recovery and 2FA recovery codes are more important. Never commit secrets or recovery codes.

## Planned work

- Choose AeroSpace or Amethyst and configure keyboard-driven workspaces.
- Add tmux, mise, Neovim and cross-platform Stow packages.
- Add Arch Linux / Omarchy support.
