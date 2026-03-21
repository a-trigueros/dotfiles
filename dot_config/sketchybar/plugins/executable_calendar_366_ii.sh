#!/bin/bash

ITEM_NAME="${NAME:-calendar_366}"
ACTION="$1"

open_calendar_366() {
  open "c366:///open?view=month" >/dev/null 2>&1
  osascript -e 'tell application "Calendar 366 II" to reopen' -e 'tell application "Calendar 366 II" to activate' >/dev/null 2>&1 || open -a "Calendar 366 II"
}

if [ "$ACTION" = "open" ] || [ "$SENDER" = "mouse.clicked" ]; then
  open_calendar_366
fi

if pgrep -x "Calendar 366 II" >/dev/null 2>&1; then
  sketchybar --set "$ITEM_NAME" drawing=on
else
  sketchybar --set "$ITEM_NAME" drawing=off
fi
