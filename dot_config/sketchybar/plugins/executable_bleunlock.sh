#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

ITEM_NAME="${NAME:-bleunlock}"
ACTION="$1"

is_bleunlock_running() {
  pgrep -x "BLEUnlock" >/dev/null 2>&1
}

toggle_bleunlock() {
  if is_bleunlock_running; then
    osascript -e 'tell application "BLEUnlock" to quit' >/dev/null 2>&1 || pkill -x "BLEUnlock" >/dev/null 2>&1
  else
    open -a "BLEUnlock" >/dev/null 2>&1
  fi
}

if [ "$ACTION" = "toggle" ] || [ "$SENDER" = "mouse.clicked" ]; then
  toggle_bleunlock
  sleep 0.2
fi

if is_bleunlock_running; then
  sketchybar --set "$ITEM_NAME" \
    icon="$ICON_LOCK_CLOSED" \
    icon.color=$GREEN \
    label.drawing=off
else
  sketchybar --set "$ITEM_NAME" \
    icon="$ICON_LOCK_OPEN" \
    icon.color=$RED \
    label.drawing=off
fi
