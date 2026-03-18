#!/bin/bash

# Plugin : now_playing.sh
# Affiche le titre en cours depuis Spotify, Music, ou tout lecteur MediaRemote

source "$CONFIG_DIR/colors.sh"

# Utilise l'event media_change fourni par sketchybar
# $INFO contient un JSON avec les infos du média

STATE=$(echo "$INFO" | plutil -extract playbackRate raw - 2>/dev/null)
TITLE=$(echo "$INFO" | plutil -extract title raw - 2>/dev/null)
ARTIST=$(echo "$INFO" | plutil -extract artist raw - 2>/dev/null)
APP=$(echo "$INFO" | plutil -extract bundleIdentifier raw - 2>/dev/null)

# Si aucune info dispo
if [ -z "$TITLE" ]; then
  sketchybar --set "$NAME" \
    drawing=off
  exit 0
fi

# Icône selon l'état play/pause
if [ "$STATE" = "1" ]; then
  ICON="󰐊"
  ICON_COLOR=$PINK
else
  ICON="󰏤"
  ICON_COLOR=$OVERLAY1
fi

# Label : tronqué si trop long
if [ -n "$ARTIST" ]; then
  LABEL="$ARTIST — $TITLE"
else
  LABEL="$TITLE"
fi

sketchybar --set "$NAME" \
  drawing=on \
  icon="$ICON" \
  icon.color=$ICON_COLOR \
  label="$LABEL"
