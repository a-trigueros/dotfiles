#!/bin/bash

# Plugin : space.sh
# $NAME = "space.1", "space.A", etc.
# On extrait le nom du workspace réel (après le point)

source "$CONFIG_DIR/colors.sh"

WS="${NAME#space.}"

FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')
WINDOWS=$(aerospace list-windows --workspace "$WS" 2>/dev/null | wc -l | tr -d ' ')

# Fallback si AeroSpace ne répond pas encore
if [ -z "$FOCUSED" ]; then
  sketchybar --set "$NAME" drawing=on icon.color=$OVERLAY1
  exit 0
fi

if [ "$FOCUSED" = "$WS" ]; then
  # Workspace actif
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color=$MAUVE \
    background.color=$SURFACE0 \
    background.border_color=$MAUVE \
    background.border_width=1
elif [ "$WINDOWS" -gt 0 ]; then
  # Workspace occupé mais pas actif
  sketchybar --set "$NAME" \
    drawing=on \
    icon.color=$SUBTEXT0 \
    background.color=$TRANSPARENT \
    background.border_color=$SURFACE1 \
    background.border_width=1
else
  # Workspace vide → masqué
  sketchybar --set "$NAME" \
    drawing=off
fi
