#! /bin/bash

git submodule update --depth 1

stow git -t $HOME
stow tmux -t $HOME

# Function to stow a directory into a specified config directory
STOW_DIR() {
    local dir="$1"
    local config_dir="${2:-$HOME/.config}"
    rm -rf "$config_dir/$dir"
    mkdir -p "$config_dir/$dir"
    stow "$dir" -t "$config_dir/$dir"
}


# Use the function for nvim et wezterm
STOW_DIR nu_scripts
STOW_DIR nvim
STOW_DIR wezterm

if [ -z "$XDG_CONFIG_HOME" ]; then
    STOW_DIR nushell "$HOME/Library/Application Support"
else
    echo "XDG_CONFIG_HOME est défini : $XDG_CONFIG_HOME"    
    STOW_DIR nushell "$XDG_CONFIG_HOME"
fi