#! /bin/bash

stow git -t $HOME
stow tmux -t $HOME
stow -t $HOME --dir=zsh root 

# Function to stow a directory into a specified config directory
STOW_DIR() {
  local dir="$1"
  local config_dir="${2:-$HOME/.config}"
  rm -rf "$config_dir/$dir"
  mkdir -p "$config_dir/$dir"
  stow "$dir" -t "$config_dir/$dir"
}

# Use the function for nvim et wezterm
STOW_DIR atuin
STOW_DIR carapace
STOW_DIR jj
STOW_DIR nvim
STOW_DIR wezterm
STOW_DIR zoxide

rm -rf "$HOME/.config/zsh"
mkdir -p "$HOME/.config/zsh"
stow --target "$HOME/.config/zsh" --dir=zsh config

if [ -z "$XDG_CONFIG_HOME" ]; then
  rm -rf "$HOME/Library/Application Support/nushell"
  mkdir -p "$HOME/Library/Application Support/nushell"
  stow --target "$HOME/Library/Application Support/nushell" --dir=nushell config
else
  STOW_DIR nushell
fi
