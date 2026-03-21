#!/bin/bash
source "$CONFIG_DIR/colors.sh"

WS="$1"

ensure_space_item() {
  local sid="$1"

  [ -z "$sid" ] && return

  if sketchybar --query "space.$sid" >/dev/null 2>&1; then
    return
  fi

  sketchybar --add item "space.$sid" left \
    --set "space.$sid" \
    icon="$sid" \
    icon.font="Hack Nerd Font:style=Bold:15.0" \
    icon.color=$OVERLAY1 \
    icon.padding_left=9 \
    icon.padding_right=9 \
    label.drawing=off \
    background.color=$TRANSPARENT \
    background.corner_radius=6 \
    background.height=28 \
    background.border_width=1 \
    background.border_color=$SURFACE0 \
    script="$CONFIG_DIR/plugins/aerospace.sh $sid"

  sketchybar --subscribe "space.$sid" aerospace_workspace_change front_app_switched
}

# Mode poll : synchronise l'état de tous les workspaces
if [ "$WS" = "poll" ]; then
  FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')
  OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)
  ALL=$(aerospace list-workspaces --all 2>/dev/null)

  for sid in $ALL; do
    ensure_space_item "$sid"
    IS_OCCUPIED=$(echo "$OCCUPIED" | grep -x "$sid")
    if [ "$sid" = "$FOCUSED" ]; then
      sketchybar --set "space.$sid" drawing=on icon.color=$MAUVE \
        background.color=$SURFACE0 background.border_color=$MAUVE background.border_width=1
    elif [ -n "$IS_OCCUPIED" ]; then
      sketchybar --set "space.$sid" drawing=on icon.color=$SUBTEXT0 \
        background.color=$TRANSPARENT background.border_color=$SURFACE1 background.border_width=1
    else
      sketchybar --set "space.$sid" drawing=off
    fi
  done
  exit 0
fi

# Mode normal : un seul workspace (appelé sur event aerospace_workspace_change)
FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')
OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)
IS_OCCUPIED=$(echo "$OCCUPIED" | grep -x "$WS")

ensure_space_item "$WS"

ITEM="space.$WS"
if [ -n "$NAME" ]; then
  ITEM="$NAME"
fi

if [ "$WS" = "$FOCUSED" ]; then
  sketchybar --set "$ITEM" drawing=on icon.color=$MAUVE \
    background.color=$SURFACE0 background.border_color=$MAUVE background.border_width=1
elif [ -n "$IS_OCCUPIED" ]; then
  sketchybar --set "$ITEM" drawing=on icon.color=$SUBTEXT0 \
    background.color=$TRANSPARENT background.border_color=$SURFACE1 background.border_width=1
else
  sketchybar --set "$ITEM" drawing=off
fi
