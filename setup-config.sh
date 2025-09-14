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
STOW_DIR atuin
STOW_DIR carapace
STOW_DIR jj
STOW_DIR nvim
STOW_DIR wezterm
STOW_DIR zoxide

if [ -z "$XDG_CONFIG_HOME" ]; then
  rm -rf "$HOME/Library/Application Support/nushell"
  mkdir -p "$HOME/Library/Application Support/nushell"
  stow --target "$HOME/Library/Application Support/nushell" --dir=nushell config
else
  STOW_DIR nushell
fi

rm -rf $HOME/.config/nushell/nu_scripts
rm -rf $HOME/.config/nushell/completions

mkdir -p $HOME/.config/nushell/nu_scripts
mkdir -p $HOME/.config/nushell/completions

stow --target $HOME/.config/nushell/nu_scripts --dir=nushell nu_scripts
stow --target $HOME/.config/nushell/completions --dir=nushell completions
