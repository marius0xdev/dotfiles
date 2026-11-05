# Interactive zsh settings managed by the dotfiles repo.
# Sourced from ~/.zshrc (bootstrap.sh appends the source line); the rest of
# ~/.zshrc stays user-managed.

# Completion: enable it unless ~/.zshrc (e.g. Oh My Zsh) already ran compinit.
# zsh ships completions for tmux, git, etc.; aliases complete like their
# targets (COMPLETE_ALIASES is off), so `t <Tab>` completes tmux commands.
if (( ! $+functions[compdef] )); then
  autoload -Uz compinit
  compinit
fi

# Vi mode for the command line (same as `bindkey -v`). Caps Lock is Escape.
set -o vi
# Switch to normal mode 10ms after Escape instead of zsh's default 400ms.
KEYTIMEOUT=1
# zsh's vi insert keymap doesn't bind Ctrl+R; keep incremental history search
# as a fallback when Atuin isn't installed.
bindkey -M viins '^R' history-incremental-search-backward
bindkey -M vicmd '^R' history-incremental-search-backward

# Atuin replaces Ctrl+R with its searchable history (after vi mode, so it binds
# the vi keymaps). The Up arrow keeps zsh's normal history navigation.
if command -v atuin >/dev/null; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi

# Aliases
alias v='nvim'
alias t='tmux'
