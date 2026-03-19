#!/bin/bash

# Plugin : amphetamine.sh
# Détecte si Amphetamine est actif (session en cours) et adapte l'icône

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Use the item name provided by sketchybar, or default to "amphetamine"
ITEM_NAME="${NAME:-amphetamine}"

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
