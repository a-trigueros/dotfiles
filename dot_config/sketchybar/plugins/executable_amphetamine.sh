#!/bin/bash

# Plugin : amphetamine.sh
# Détecte si Amphetamine est actif (session en cours) et adapte l'icône

source "$CONFIG_DIR/colors.sh"

# On vérifie si le process "Amphetamine" tourne ET si une session est active.
# Amphetamine expose un helper CLI via osascript.
IS_ACTIVE=$(osascript -e '
  tell application "System Events"
    if exists process "Amphetamine" then
      tell application "Amphetamine"
        return appIsActive()
      end tell
    else
      return false
    end if
  end tell
' 2>/dev/null)

if [ "$IS_ACTIVE" = "true" ]; then
  sketchybar --set "$NAME" \
    icon="󰅶" \
    icon.color=$YELLOW \
    label.drawing=off
else
  sketchybar --set "$NAME" \
    icon="󰅶" \
    icon.color=$OVERLAY0 \
    label.drawing=off
fi
