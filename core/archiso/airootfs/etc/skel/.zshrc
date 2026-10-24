# ==============================================================================
# KAZE OS: USER ZSH CONFIGURATION (~/.zshrc)
# ==============================================================================

autoload -Uz compinit && compinit
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_DUPS

alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias grep='grep --color=auto'
alias kaze='kaze-cli'

PROMPT='%F{cyan}%n@kaze%f:%F{blue}%~%f$ '
