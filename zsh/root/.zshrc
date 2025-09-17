# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Enable zsh completion
# Cache compinit pour accélérer le démarrage
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit -C   # utilise le cache si moins de 24h
else
  compinit
fi

setopt autocd              # implicit cd
setopt correct             # fix typos
setopt histignoredups      # no duplicates in history
setopt sharehistory        # share history across sessions

source $HOME/.config/zsh/node.zsh
source $HOME/.config/zsh/devtoolstosort.zsh

source $HOME/.config/zsh/starship.zsh
source $HOME/.config/zsh/atuin.zsh
source $HOME/.config/zsh/carapace.zsh
source $HOME/.config/zsh/zoxide.zsh


source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ⚠️ Always load last
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias nv=nvim
export EDITOR=nvim

set -o vi

zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
LISTMAX=0
