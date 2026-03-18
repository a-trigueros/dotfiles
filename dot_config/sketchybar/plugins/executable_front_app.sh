#!/bin/bash

# Plugin : front_app.sh
# Affiche l'icône + nom de l'application au premier plan

source "$CONFIG_DIR/colors.sh"

# Mapping app → icône Nerd Font
case "$INFO" in
  "Finder")        ICON="󰀶" ;;
  "Safari")        ICON="󰖟" ;;
  "Firefox")       ICON="󰈹" ;;
  "Arc")           ICON="󰌷" ;;
  "Terminal")      ICON="" ;;
  "iTerm2")        ICON="" ;;
  "Ghostty")       ICON="󰊠" ;;
  "Alacritty")     ICON="" ;;
  "kitty")         ICON="󰄛" ;;
  "Warp")          ICON="󱃖" ;;
  "Visual Studio Code") ICON="󰨞" ;;
  "Code")          ICON="󰨞" ;;
  "Cursor")        ICON="󰨞" ;;
  "Neovide")       ICON="" ;;
  "Xcode")         ICON="󰀵" ;;
  "Slack")         ICON="󰒱" ;;
  "Discord")       ICON="󰙯" ;;
  "Telegram")      ICON="" ;;
  "WhatsApp")      ICON="󰖣" ;;
  "Mail")          ICON="󰇮" ;;
  "Spark")         ICON="󰇮" ;;
  "Spotify")       ICON="󰓇" ;;
  "Music")         ICON="󰝚" ;;
  "Figma")         ICON="󰙏" ;;
  "Sketch")        ICON="󰿦" ;;
  "Notion")        ICON="󱄑" ;;
  "Obsidian")      ICON="󰉻" ;;
  "Raycast")       ICON="󱒄" ;;
  "1Password 7 - Password Manager") ICON="󰌋" ;;
  "1Password")     ICON="󰌋" ;;
  "Amphetamine")   ICON="󰅶" ;;
  "System Preferences") ICON="󰒓" ;;
  "System Settings")    ICON="󰒓" ;;
  "Activity Monitor")   ICON="󰺁" ;;
  *)               ICON="󰣆" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="$INFO"
