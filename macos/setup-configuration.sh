#! /bin/bash

cd "$(dirname "$0")/.."

git submodule init
git submodule update --depth 1

# Checkout specific tag for tmux catppuccin theme
cd tmux/themes/catppuccin && git checkout v2.1.3 && cd -

rm -f $HOME/.gitconfig
stow git -t $HOME

rm -f $HOME/.tmux.conf
stow -t $HOME --dir=tmux config

rm -f $HOME/.zshrc
stow -t $HOME --dir=zsh root

mkdir -p $HOME/.config

rm -f $HOME/.config/starship.toml
stow starship -t $HOME/.config

rm -rf $HOME/.config/tmux/themes
mkdir -p $HOME/.config/tmux/themes
stow --target=$HOME/.config/tmux/themes --dir=tmux themes

rm -rf $HOME/.config/jetbrains/Lazy-idea
mkdir -p $HOME/.config/jetbrains/Lazy-idea
stow --target=$HOME/.config/jetbrains/Lazy-idea --dir=jetbrains Lazy-idea

rm -f $HOME/.ideavimrc
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
stow --target "$HOME/.config/nvim" --dir="nvim" LazyVim

# Custom config
rm "$HOME/.config/nvim/lua/config/keymaps.lua"
stow --target "$HOME/.config/nvim/lua" --dir="nvim" lua

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
