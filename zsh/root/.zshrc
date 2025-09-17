# ----- Basic options -----
setopt autocd              # cd implicite
setopt correct             # corrige les fautes de frappe
setopt histignoredups      # pas de doublons dans l’historique
setopt sharehistory        # partage entre sessions

# ----- Compinit (Zsh completions) -----
# Uses compinit cache if lesser than 24h
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -C
else
  compinit
fi

# ----- Prompt -----
eval "$(starship init zsh)"

# ----- Completion (Carapace) -----
eval "$(carapace _carapace)"

# ----- History (Atuin) -----
# Chargé uniquement en mode interactif
if [[ $- == *i* ]]; then
  eval "$(atuin init zsh)"
fi

# ----- Fast cd (zoxide) -----
eval "$(zoxide init zsh)"

# ----- Fuzzy finder (fzf) -----
# Only in interactive shell
if [[ $- == *i* ]]; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# ----- Autosuggestions -----
if [[ $- == *i* ]]; then
  source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# ----- Syntax highlighting -----
# ⚠️ always last, and only in interactive mode
if [[ $- == *i* ]]; then
  source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

source $HOME/.config/zsh/node.zsh
source $HOME/.config/zsh/devtoolstosort.zsh

alias nv=nvim
alias ls='ls -G'
alias cd=z
export EDITOR=nvim

set -o vi

zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
LISTMAX=0
