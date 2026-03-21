#!/bin/bash

CLOCK_FORMAT="%a %d %b  %H:%M"
TARGET_ITEM="$NAME"

get_clock_label() {
  date "+$CLOCK_FORMAT"
}

set_clock_item() {
  local label
  label="$(get_clock_label)"
  sketchybar --set "$TARGET_ITEM" label="$label"
}

set_clock_item
