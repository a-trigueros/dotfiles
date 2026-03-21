#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

ACTION="${1:-render}"
TARGET_WINDOW_ID="$2"

get_app_icon() {
  local app_name="$1"

  case "$app_name" in
    "Finder") printf "󰀶" ;;
    "Safari") printf "󰖟" ;;
    "Firefox") printf "󰈹" ;;
    "Arc") printf "󰌷" ;;
    "Ghostty") printf "󰊠" ;;
    "kitty") printf "󰄛" ;;
    "Warp") printf "󱃖" ;;
    "Visual Studio Code"|"Code"|"Cursor") printf "󰨞" ;;
    "Xcode") printf "󰀵" ;;
    "Slack") printf "󰒱" ;;
    "Discord") printf "󰙯" ;;
    "WhatsApp") printf "󰖣" ;;
    "Mail"|"Spark") printf "󰇮" ;;
    "Spotify") printf "󰓇" ;;
    "Music") printf "󰝚" ;;
    "Figma") printf "󰙏" ;;
    "Notion") printf "󱄑" ;;
    "Obsidian") printf "󰉻" ;;
    "Raycast") printf "󱒄" ;;
    "1Password"|"1Password 7 - Password Manager") printf "󰌋" ;;
    *) printf "%s" "$ICON_APP_DEFAULT" ;;
  esac
}

if [ "$ACTION" = "focus" ] && [ -n "$TARGET_WINDOW_ID" ]; then
  aerospace focus --window-id "$TARGET_WINDOW_ID" >/dev/null 2>&1
fi

FOCUSED_WORKSPACE="$(aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')"
FOCUSED_WINDOW_ID="$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null | tr -d '[:space:]')"

sketchybar --remove '/workspace_app\..*/' >/dev/null 2>&1

[ -z "$FOCUSED_WORKSPACE" ] && exit 0

WINDOWS_RAW="$(aerospace list-windows --workspace "$FOCUSED_WORKSPACE" --format '%{window-id}|%{app-name}' 2>/dev/null)"
[ -z "$WINDOWS_RAW" ] && exit 0

APPS="$(printf "%s\n" "$WINDOWS_RAW" | awk -F'|' '!seen[$2]++ {print $1 "|" $2}')"

anchor_item="separator_left"
while IFS='|' read -r window_id app_name; do
  [ -z "$window_id" ] && continue
  [ -z "$app_name" ] && continue

  item_name="workspace_app.$window_id"
  icon="$(get_app_icon "$app_name")"

  if [ "$window_id" = "$FOCUSED_WINDOW_ID" ]; then
    icon_color="$MAUVE"
    label_color="$TEXT"
    bg_color="$SURFACE0"
    border_color="$MAUVE"
  else
    icon_color="$SUBTEXT0"
    label_color="$SUBTEXT1"
    bg_color="$TRANSPARENT"
    border_color="$SURFACE1"
  fi

  sketchybar --add item "$item_name" left \
    --set "$item_name" \
    icon="$icon" \
    icon.font="Hack Nerd Font:style=Regular:14.0" \
    icon.color="$icon_color" \
    label="$app_name" \
    label.max_chars=18 \
    label.color="$label_color" \
    background.color="$bg_color" \
    background.corner_radius=6 \
    background.height=28 \
    background.border_width=1 \
    background.border_color="$border_color" \
    click_script="$CONFIG_DIR/plugins/workspace_apps.sh focus $window_id"

  sketchybar --move "$item_name" after "$anchor_item"
  anchor_item="$item_name"
done <<< "$APPS"
