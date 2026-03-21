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

  url="https://wttr.in/${location}?format=%t|%C|%S|%s|%T"
  curl -sf --max-time 5 "$url" 2>/dev/null
}

set_unavailable_item() {
  sketchybar --set "$ITEM_NAME" \
    icon="󰖐" \
    icon.color=$OVERLAY0 \
    label="--"
}

trim_value() {
  local value="$1"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"
  printf '%s\n' "$value"
}

parse_weather_snapshot() {
  local snapshot="$1"
  local temp
  local rest
  local condition
  local sunrise
  local sunset
  local current_time

  temp="${snapshot%%|*}"
  rest="${snapshot#*|}"
  condition="${rest%%|*}"
  rest="${rest#*|}"
  sunrise="${rest%%|*}"
  rest="${rest#*|}"
  sunset="${rest%%|*}"
  current_time="${rest#*|}"

  printf '%s|%s|%s|%s|%s\n' \
    "$(trim_value "$temp")" \
    "$(trim_value "$condition")" \
    "$(trim_value "$sunrise")" \
    "$(trim_value "$sunset")" \
    "$(trim_value "$current_time")"
}

time_to_minutes() {
  local raw_time="$1"
  local t
  local suffix=""
  local hour
  local minute

  t="$(trim_value "$raw_time")"
  t="$(printf '%s' "$t" | tr '[:lower:]' '[:upper:]')"

  case "$t" in
    *" AM")
      suffix="AM"
      t="${t% AM}"
      ;;
    *" PM")
      suffix="PM"
      t="${t% PM}"
      ;;
  esac

  case "$t" in
    *:*)
      ;;
    *)
      return 1
      ;;
  esac

  hour="${t%%:*}"
  minute="${t#*:}"
  hour="$(trim_value "$hour")"
  minute="$(trim_value "$minute")"

  case "$hour" in
    "" | *[!0-9]*)
      return 1
      ;;
  esac

  case "$minute" in
    "" | *[!0-9]*)
      return 1
      ;;
  esac

  if [ "$minute" -gt 59 ]; then
    return 1
  fi

  if [ -n "$suffix" ]; then
    if [ "$hour" -lt 1 ] || [ "$hour" -gt 12 ]; then
      return 1
    fi

    if [ "$suffix" = "AM" ] && [ "$hour" -eq 12 ]; then
      hour=0
    elif [ "$suffix" = "PM" ] && [ "$hour" -lt 12 ]; then
      hour=$((hour + 12))
    fi
  else
    if [ "$hour" -gt 23 ]; then
      return 1
    fi
  fi

  printf '%s\n' $((10#$hour * 60 + 10#$minute))
}

is_night_for_location() {
  local current_time="$1"
  local sunrise="$2"
  local sunset="$3"
  local current_minutes
  local sunrise_minutes
  local sunset_minutes
  local local_hour

  current_minutes="$(time_to_minutes "$current_time")"
  sunrise_minutes="$(time_to_minutes "$sunrise")"
  sunset_minutes="$(time_to_minutes "$sunset")"

  if [ -n "$current_minutes" ] && [ -n "$sunrise_minutes" ] && [ -n "$sunset_minutes" ] && [ "$sunrise_minutes" -lt "$sunset_minutes" ]; then
    if [ "$current_minutes" -lt "$sunrise_minutes" ] || [ "$current_minutes" -ge "$sunset_minutes" ]; then
      printf '%s\n' "1"
      return
    fi

    printf '%s\n' "0"
    return
  fi

  local_hour="$(date +%H)"
  if [ "$local_hour" -lt 7 ] || [ "$local_hour" -ge 20 ]; then
    printf '%s\n' "1"
    return
  fi

  printf '%s\n' "0"
}

resolve_icon_and_color() {
  local condition="$1"
  local is_night="$2"
  local condition_lc

  condition_lc="$(printf '%s' "$condition" | tr '[:upper:]' '[:lower:]')"

  case "$condition_lc" in
    *sun* | *clear*)
      if [ "$is_night" = "1" ]; then
        printf '%s|%s\n' "󰽥" "$LAVENDER"
      else
        printf '%s|%s\n' "󰖙" "$YELLOW"
      fi
      ;;
    *cloud* | *overcast*)
      if [ "$is_night" = "1" ]; then
        printf '%s|%s\n' "󰖐" "$OVERLAY1"
      else
        printf '%s|%s\n' "󰖐" "$SUBTEXT1"
      fi
      ;;
    *rain* | *drizzle* | *shower*)
      if [ "$is_night" = "1" ]; then
        printf '%s|%s\n' "󰖗" "$BLUE"
      else
        printf '%s|%s\n' "󰖗" "$SAPPHIRE"
      fi
      ;;
    *snow* | *sleet* | *blizzard*)
      if [ "$is_night" = "1" ]; then
        printf '%s|%s\n' "󰖘" "$LAVENDER"
      else
        printf '%s|%s\n' "󰖘" "$TEXT"
      fi
      ;;
    *thunder* | *storm*)
      if [ "$is_night" = "1" ]; then
        printf '%s|%s\n' "󰖓" "$LAVENDER"
      else
        printf '%s|%s\n' "󰖓" "$MAUVE"
      fi
      ;;
    *fog* | *mist* | *haze*)
      if [ "$is_night" = "1" ]; then
        printf '%s|%s\n' "󰖑" "$OVERLAY2"
      else
        printf '%s|%s\n' "󰖑" "$OVERLAY1"
      fi
      ;;
    *)
      if [ "$is_night" = "1" ]; then
        printf '%s|%s\n' "󰽥" "$LAVENDER"
      else
        printf '%s|%s\n' "󰖙" "$SKY"
      fi
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
  local sunrise
  local sunset
  local current_time
  local night_flag
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
  parsed="${parsed#*|}"
  condition="${parsed%%|*}"
  parsed="${parsed#*|}"
  sunrise="${parsed%%|*}"
  parsed="${parsed#*|}"
  sunset="${parsed%%|*}"
  current_time="${parsed#*|}"

  night_flag="$(is_night_for_location "$current_time" "$sunrise" "$sunset")"
  icon_and_color="$(resolve_icon_and_color "$condition" "$night_flag")"
  icon="${icon_and_color%%|*}"
  color="${icon_and_color#*|}"

  set_weather_item "$icon" "$color" "$temperature"
}

main
