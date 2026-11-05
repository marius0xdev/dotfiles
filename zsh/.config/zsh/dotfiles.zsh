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

# Aliases
alias v='nvim'
alias t='tmux'
