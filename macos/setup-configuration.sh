#! /bin/bash

cd "$(dirname "$0")/.."

git submodule init
git submodule update --depth 1

rm -f $HOME/.gitconfig
stow git -t $HOME

rm -f $HOME/.tmux.conf
stow tmux -t $HOME

rm -f $HOME/.zshrc
stow -t $HOME --dir=zsh root

mkdir -p $HOME/.config

rm -f $HOME/.config/starship.toml
rm -f $HOME/.config/starship-powershell.toml
stow starship -t $HOME/.config

rm -f ~/.ideavimrc
stow --target=$HOME --dir=jetbrains ideavimrc

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
STOW_DIR bat
STOW_DIR jj
STOW_DIR ghostty
STOW_DIR wezterm
STOW_DIR zellij

bat cache --build

# Nvim configuration
rm -rf "$HOME/.config/nvim"
mkdir -p "$HOME/.config/nvim"
stow --target "$HOME/.config/nvim" LazyVim

# Custom config
rm "$HOME/.config/nvim/lua/config/keymaps.lua"
stow --target "$HOME/.config/nvim/lua/config" --dir="nvim/lua" config

# Zsh configuration
rm -rf "$HOME/.config/zsh"
mkdir -p "$HOME/.config/zsh"
stow --target "$HOME/.config/zsh" --dir=zsh config

# Karabiner configuration
rm -rf "$HOME/.config/karabiner"
mkdir -p "$HOME/.config/karabiner"
stow --target "$HOME/.config/karabiner" karabiner

# Nushell configuration
if [ -z "$XDG_CONFIG_HOME" ]; then
  rm -rf "$HOME/Library/Application Support/nushell"
  mkdir -p "$HOME/Library/Application Support/nushell"
  stow --target "$HOME/Library/Application Support/nushell" --dir=nushell config
else
  STOW_DIR nushell
fi

PWSH_PROFILE_DIR=$(pwsh -NoProfile -Command 'Split-Path $PROFILE')
rm -f "$PWSH_PROFILE_DIR/Microsoft.PowerShell_profile.ps1"
mkdir -p "$PWSH_PROFILE_DIR"
stow powershell -t "$PWSH_PROFILE_DIR"
