#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="${NAME:-day_phase}"

hour_now() {
  date +%H
}

phase_for_hour() {
  local hour="$1"

  if [ "$hour" -ge 5 ] && [ "$hour" -lt 12 ]; then
    printf '%s\n' "matin"
    return
  fi

  if [ "$hour" -ge 12 ] && [ "$hour" -lt 18 ]; then
    printf '%s\n' "apres-midi"
    return
  fi

  if [ "$hour" -ge 18 ] && [ "$hour" -lt 22 ]; then
    printf '%s\n' "soiree"
    return
  fi

  printf '%s\n' "nuit"
}

icon_and_color_for_phase() {
  local phase="$1"

  case "$phase" in
    matin)
      printf '%s|%s\n' "󰖨" "$YELLOW"
      ;;
    apres-midi)
      printf '%s|%s\n' "󰖙" "$YELLOW"
      ;;
    soiree)
      printf '%s|%s\n' "󰖛" "$PEACH"
      ;;
    *)
      printf '%s|%s\n' "󰽥" "$LAVENDER"
      ;;
  esac
}

main() {
  local hour
  local phase
  local icon_and_color
  local icon
  local color

  hour="$(hour_now)"
  phase="$(phase_for_hour "$hour")"
  icon_and_color="$(icon_and_color_for_phase "$phase")"
  icon="${icon_and_color%%|*}"
  color="${icon_and_color#*|}"

  sketchybar --set "$ITEM_NAME" \
    icon="$icon" \
    icon.color=$color
}

main
