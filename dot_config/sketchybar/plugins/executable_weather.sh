#!/bin/bash

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="${NAME:-weather}"
LOCATION="${WEATHER_LOCATION:-}"

normalize_location() {
  local raw_location="$1"

  if [ -z "$raw_location" ]; then
    printf '%s\n' ""
    return
  fi

  printf '%s\n' "${raw_location// /+}"
}

fetch_weather_snapshot() {
  local location="$1"
  local url

  url="https://wttr.in/${location}?format=%t|%C"
  curl -sf --max-time 5 "$url" 2>/dev/null
}

set_unavailable_item() {
  sketchybar --set "$ITEM_NAME" \
    icon="󰖐" \
    icon.color=$OVERLAY0 \
    label="--"
}

parse_weather_snapshot() {
  local snapshot="$1"
  local temp
  local condition

  temp="${snapshot%%|*}"
  condition="${snapshot#*|}"

  printf '%s|%s\n' "$temp" "$condition"
}

resolve_icon_and_color() {
  local condition="$1"
  local condition_lc

  condition_lc="$(printf '%s' "$condition" | tr '[:upper:]' '[:lower:]')"

  case "$condition_lc" in
    *sun* | *clear*)
      printf '%s|%s\n' "󰖙" "$YELLOW"
      ;;
    *cloud* | *overcast*)
      printf '%s|%s\n' "󰖐" "$SUBTEXT1"
      ;;
    *rain* | *drizzle* | *shower*)
      printf '%s|%s\n' "󰖗" "$SAPPHIRE"
      ;;
    *snow* | *sleet* | *blizzard*)
      printf '%s|%s\n' "󰖘" "$TEXT"
      ;;
    *thunder* | *storm*)
      printf '%s|%s\n' "󰖓" "$MAUVE"
      ;;
    *fog* | *mist* | *haze*)
      printf '%s|%s\n' "󰖑" "$OVERLAY1"
      ;;
    *)
      printf '%s|%s\n' "󰖙" "$SKY"
      ;;
  esac
}

set_weather_item() {
  local icon="$1"
  local color="$2"
  local temperature="$3"

  sketchybar --set "$ITEM_NAME" \
    icon="$icon" \
    icon.color=$color \
    label="$temperature"
}

main() {
  local normalized_location
  local snapshot
  local parsed
  local temperature
  local condition
  local icon_and_color
  local icon
  local color

  normalized_location="$(normalize_location "$LOCATION")"
  snapshot="$(fetch_weather_snapshot "$normalized_location")"

  if [ -z "$snapshot" ]; then
    set_unavailable_item
    return
  fi

  parsed="$(parse_weather_snapshot "$snapshot")"
  temperature="${parsed%%|*}"
  condition="${parsed#*|}"

  icon_and_color="$(resolve_icon_and_color "$condition")"
  icon="${icon_and_color%%|*}"
  color="${icon_and_color#*|}"

  set_weather_item "$icon" "$color" "$temperature"
}

main
