#!/bin/bash

source "$CONFIG_DIR/colors.sh"

TARGET_ITEM="$NAME"

ICON_PLAYING="󰐊"
ICON_PAUSED="󰏤"
COLOR_PLAYING="$PINK"
COLOR_PAUSED="$OVERLAY1"

get_media_value() {
  local key="$1"
  printf "%s\n" "$INFO" | plutil -extract "$key" raw - 2>/dev/null
}

is_media_available() {
  local title="$1"
  [ -n "$title" ]
}

is_media_playing() {
  local playback_rate="$1"
  [ "$playback_rate" = "1" ]
}

get_media_icon() {
  local playback_rate="$1"
  if is_media_playing "$playback_rate"; then
    printf "%s" "$ICON_PLAYING"
    return
  fi

  printf "%s" "$ICON_PAUSED"
}

get_media_icon_color() {
  local playback_rate="$1"
  if is_media_playing "$playback_rate"; then
    printf "%s" "$COLOR_PLAYING"
    return
  fi

  printf "%s" "$COLOR_PAUSED"
}

get_media_label() {
  local artist="$1"
  local title="$2"

  if [ -n "$artist" ]; then
    printf "%s — %s" "$artist" "$title"
    return
  fi

  printf "%s" "$title"
}

set_now_playing_hidden() {
  sketchybar --set "$TARGET_ITEM" drawing=off
}

set_now_playing_visible() {
  local icon="$1"
  local icon_color="$2"
  local label="$3"

  sketchybar --set "$TARGET_ITEM" \
    drawing=on \
    icon="$icon" \
    icon.color=$icon_color \
    label="$label"
}

PLAYBACK_RATE="$(get_media_value playbackRate)"
TITLE="$(get_media_value title)"
ARTIST="$(get_media_value artist)"

if ! is_media_available "$TITLE"; then
  set_now_playing_hidden
  exit 0
fi

ICON="$(get_media_icon "$PLAYBACK_RATE")"
ICON_COLOR="$(get_media_icon_color "$PLAYBACK_RATE")"
LABEL="$(get_media_label "$ARTIST" "$TITLE")"

set_now_playing_visible "$ICON" "$ICON_COLOR" "$LABEL"
