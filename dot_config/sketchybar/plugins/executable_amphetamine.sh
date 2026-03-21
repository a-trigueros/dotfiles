#!/bin/bash

# Plugin : amphetamine.sh
# Détecte si Amphetamine est actif (session en cours) et adapte l'icône

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Use the item name provided by sketchybar, or default to "amphetamine"
ITEM_NAME="${NAME:-amphetamine}"
ACTION="$1"

toggle_amphetamine_session() {
	if osascript -e 'tell application "Amphetamine" to session is active' 2>/dev/null | grep -q "true"; then
		osascript -e 'tell application "Amphetamine" to end session' >/dev/null 2>&1
	else
		osascript -e 'tell application "Amphetamine" to start new session' >/dev/null 2>&1
	fi
}

if [ "$ACTION" = "toggle" ] || [ "$SENDER" = "mouse.clicked" ]; then
	toggle_amphetamine_session
fi

# Check if Amphetamine has an active assertion (session)
if pmset -g assertions | grep -q "Amphetamine"; then
	# Amphetamine has an active assertion - show ON state
	sketchybar --set "$ITEM_NAME" \
		icon="$ICON_COFFEE_ON" \
		icon.color=$YELLOW \
		label.drawing=off
else
	# No active assertion by Amphetamine - show OFF state
	sketchybar --set "$ITEM_NAME" \
		icon="$ICON_COFFEE_OFF" \
		icon.color=$OVERLAY0 \
		label.drawing=off
fi
