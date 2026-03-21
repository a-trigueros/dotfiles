#!/bin/bash

source "$CONFIG_DIR/colors.sh"

TARGET_ITEM="$NAME"
TARGET_APP="$INFO"
DEFAULT_APP_ICON="󰣆"

get_front_app_icon() {
  local app_name="$1"

  case "$app_name" in
    "Finder")        printf "󰀶" ;;
    "Safari")        printf "󰖟" ;;
    "Firefox")       printf "󰈹" ;;
    "Arc")           printf "󰌷" ;;
    "Terminal")      printf "" ;;
    "iTerm2")        printf "" ;;
    "Ghostty")       printf "󰊠" ;;
    "Alacritty")     printf "" ;;
    "kitty")         printf "󰄛" ;;
    "Warp")          printf "󱃖" ;;
    "Visual Studio Code") printf "󰨞" ;;
    "Code")          printf "󰨞" ;;
    "Cursor")        printf "󰨞" ;;
    "Neovide")       printf "" ;;
    "Xcode")         printf "󰀵" ;;
    "Slack")         printf "󰒱" ;;
    "Discord")       printf "󰙯" ;;
    "Telegram")      printf "" ;;
    "WhatsApp")      printf "󰖣" ;;
    "Mail")          printf "󰇮" ;;
    "Spark")         printf "󰇮" ;;
    "Spotify")       printf "󰓇" ;;
    "Music")         printf "󰝚" ;;
    "Figma")         printf "󰙏" ;;
    "Sketch")        printf "󰿦" ;;
    "Notion")        printf "󱄑" ;;
    "Obsidian")      printf "󰉻" ;;
    "Raycast")       printf "󱒄" ;;
    "1Password 7 - Password Manager") printf "󰌋" ;;
    "1Password")     printf "󰌋" ;;
    "Amphetamine")   printf "󰅶" ;;
    "System Preferences") printf "󰒓" ;;
    "System Settings")    printf "󰒓" ;;
    "Activity Monitor")   printf "󰺁" ;;
    *)               printf "%s" "$DEFAULT_APP_ICON" ;;
  esac
}

set_front_app_item() {
  local icon
  icon="$(get_front_app_icon "$TARGET_APP")"

  sketchybar --set "$TARGET_ITEM" \
    icon="$icon" \
    label="$TARGET_APP"
}

set_front_app_item
