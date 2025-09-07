#! /bin/bash

stow git -t $HOME
stow tmux -t $HOME

mkdir -p $HOME/.config/nvim
stow nvim -t $HOME/.config/nvim

mkdir -p $HOME/.config/wezterm
stow wezterm -t $HOME/.config/wezterm

if [ -z "$XDG_CONFIG_HOME" ]; then
    mkdir -p "$HOME/Library/Application Support/nushell"
    stow nushell -t "$HOME/Library/Application Support/nushell"
else
    echo "XDG_CONFIG_HOME est défini : $XDG_CONFIG_HOME"    
    mkdir -p $XDG_CONFIG_HOME/nushell
fi