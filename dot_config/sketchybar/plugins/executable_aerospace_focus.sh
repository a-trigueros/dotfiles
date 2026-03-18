#!/bin/bash
source "$CONFIG_DIR/colors.sh"

WS="$1"

# Mode poll : synchronise l'état de tous les workspaces
if [ "$WS" = "poll" ]; then
  FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')
  OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)
  ALL=$(aerospace list-workspaces --all 2>/dev/null)

  for sid in $ALL; do
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

if [ "$WS" = "$FOCUSED" ]; then
  sketchybar --set "$NAME" drawing=on icon.color=$MAUVE \
    background.color=$SURFACE0 background.border_color=$MAUVE background.border_width=1
elif [ -n "$IS_OCCUPIED" ]; then
  sketchybar --set "$NAME" drawing=on icon.color=$SUBTEXT0 \
    background.color=$TRANSPARENT background.border_color=$SURFACE1 background.border_width=1
else
  sketchybar --set "$NAME" drawing=off
fi
