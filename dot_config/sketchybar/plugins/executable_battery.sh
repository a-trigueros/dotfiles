#!/bin/bash

# Plugin : battery.sh
# Shows the battery percentage as well as if its currently charging or not

source "$CONFIG_DIR/colors.sh"

ITEM_NAME="${NAME:-battery}"

read_battery_snapshot() {
  local info
  local percent
  local status
  local power_source

  info=$(pmset -g batt 2>/dev/null)
  percent=$(printf '%s\n' "$info" | awk 'match($0, /[0-9]+%/) { print substr($0, RSTART, RLENGTH); exit }')
  status=$(printf '%s\n' "$info" | awk -F'; *' 'NR==2 { print tolower($2) }')
  power_source=$(printf '%s\n' "$info" | awk 'NR==1 { print tolower($0) }')

  printf '%s|%s|%s\n' "$percent" "$status" "$power_source"
}

discharging_icon_for_pct() {
  local pct="$1"

  if [ "$pct" -ge 90 ]; then
    printf '%s\n' ""
  elif [ "$pct" -ge 65 ]; then
    printf '%s\n' ""
  elif [ "$pct" -ge 40 ]; then
    printf '%s\n' ""
  elif [ "$pct" -ge 15 ]; then
    printf '%s\n' ""
  else
    printf '%s\n' ""
  fi
}

charging_icon_for_pct() {
  local pct="$1"

  if [ "$pct" -ge 95 ]; then
    printf '%s\n' "󰂅"
  elif [ "$pct" -ge 85 ]; then
    printf '%s\n' "󰂋"
  elif [ "$pct" -ge 75 ]; then
    printf '%s\n' "󰂊"
  elif [ "$pct" -ge 65 ]; then
    printf '%s\n' "󰢞"
  elif [ "$pct" -ge 55 ]; then
    printf '%s\n' "󰂉"
  elif [ "$pct" -ge 45 ]; then
    printf '%s\n' "󰢝"
  elif [ "$pct" -ge 35 ]; then
    printf '%s\n' "󰂈"
  elif [ "$pct" -ge 25 ]; then
    printf '%s\n' "󰂇"
  elif [ "$pct" -ge 15 ]; then
    printf '%s\n' "󰂆"
  else
    printf '%s\n' "󰢜"
  fi
}

discharging_color_for_pct() {
  local pct="$1"

  if [ "$pct" -le 20 ]; then
    printf '%s\n' "$RED"
  elif [ "$pct" -le 40 ]; then
    printf '%s\n' "$PEACH"
  else
    printf '%s\n' "$SUBTEXT1"
  fi
}

is_charging_status() {
  local status="$1"
  local power_source="$2"

  case "$status" in
  charging | charged | "finishing charge" | "en charge")
    return 0
    ;;
  esac

  case "$power_source" in
  *"ac power"* | *external* | *adapt* | *secteur*)
    return 0
    ;;
  esac

  return 1
}

SNAPSHOT=$(read_battery_snapshot)
PERCENT=${SNAPSHOT%%|*}
REST=${SNAPSHOT#*|}
STATUS=${REST%%|*}
POWER_SOURCE=${REST#*|}

if [ -z "$PERCENT" ]; then
  sketchybar --set "$ITEM_NAME" icon="" icon.color=$OVERLAY0 label="N/A"
  exit 0
fi

PCT=${PERCENT%%%}
LABEL="$PERCENT"

if is_charging_status "$STATUS" "$POWER_SOURCE"; then
  ICON=$(charging_icon_for_pct "$PCT")
  COLOR=$GREEN
else
  ICON=$(discharging_icon_for_pct "$PCT")
  COLOR=$(discharging_color_for_pct "$PCT")
fi

sketchybar --set "$ITEM_NAME" \
  icon="$ICON" \
  icon.color=$COLOR \
  label="$LABEL"
