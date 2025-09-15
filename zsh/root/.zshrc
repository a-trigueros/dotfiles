# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

source $HOME/.config/zsh/oh-my-zsh.zsh
source $HOME/.config/atuin/init.zsh
source $HOME/.config/carapace/init.zsh

source $HOME/.config/zsh/node.zsh
source $HOME/.config/zsh/devtoolstosort.zsh

alias nv=nvim
export EDITOR=nvim

set -o vi

zstyle ':completion:*' list-prompt ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' menu select
LISTMAX=0
