#!/bin/bash

# Plugin : battery.sh
# Affiche le pourcentage de batterie et l'etat de charge

source "$CONFIG_DIR/colors.sh"

BATTERY_INFO=$(pmset -g batt 2>/dev/null)
PERCENT=$(printf '%s\n' "$BATTERY_INFO" | awk 'match($0, /[0-9]+%/) { print substr($0, RSTART, RLENGTH); exit }')
STATUS=$(printf '%s\n' "$BATTERY_INFO" | awk -F'; *' 'NR==2 { print tolower($2) }')

if [ -z "$PERCENT" ]; then
  sketchybar --set "$NAME" icon="" icon.color=$OVERLAY0 label="N/A"
  exit 0
fi

PCT=${PERCENT%%%}

if [ "$PCT" -ge 90 ]; then
  ICON=""
elif [ "$PCT" -ge 65 ]; then
  ICON=""
elif [ "$PCT" -ge 40 ]; then
  ICON=""
elif [ "$PCT" -ge 15 ]; then
  ICON=""
else
  ICON=""
fi

case "$STATUS" in
  charging|charged|"finishing charge")
    LABEL="$PERCENT"
    if [ "$PCT" -ge 95 ]; then
      ICON="󰂅"
    elif [ "$PCT" -ge 85 ]; then
      ICON="󰂋"
    elif [ "$PCT" -ge 75 ]; then
      ICON="󰂊"
    elif [ "$PCT" -ge 65 ]; then
      ICON="󰢞"
    elif [ "$PCT" -ge 55 ]; then
      ICON="󰂉"
    elif [ "$PCT" -ge 45 ]; then
      ICON="󰢝"
    elif [ "$PCT" -ge 35 ]; then
      ICON="󰂈"
    elif [ "$PCT" -ge 25 ]; then
      ICON="󰂇"
    elif [ "$PCT" -ge 15 ]; then
      ICON="󰂆"
    else
      ICON="󰢜"
    fi
    COLOR=$GREEN
    ;;
  *)
    LABEL="$PERCENT"
    if [ "$PCT" -le 20 ]; then
      COLOR=$RED
    elif [ "$PCT" -le 40 ]; then
      COLOR=$PEACH
    else
      COLOR=$SUBTEXT1
    fi
    ;;
esac

sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color=$COLOR \
  label="$LABEL"
