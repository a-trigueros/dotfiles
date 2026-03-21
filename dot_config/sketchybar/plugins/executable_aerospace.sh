#!/bin/bash

source "$CONFIG_DIR/colors.sh"

TARGET_WORKSPACE="$1"

# Item defaults
SPACE_ICON_FONT="Hack Nerd Font:style=Bold:15.0"
SPACE_ICON_PADDING_LEFT=9
SPACE_ICON_PADDING_RIGHT=9
SPACE_BG_CORNER_RADIUS=6
SPACE_BG_HEIGHT=28
SPACE_BG_BORDER_WIDTH=1

# States
STATE_FOCUSED="focused"
STATE_OCCUPIED="occupied"
STATE_EMPTY="empty"

# State styles
FOCUSED_ICON_COLOR="$MAUVE"
FOCUSED_BG_COLOR="$SURFACE0"
FOCUSED_BORDER_COLOR="$MAUVE"

OCCUPIED_ICON_COLOR="$SUBTEXT0"
OCCUPIED_BG_COLOR="$TRANSPARENT"
OCCUPIED_BORDER_COLOR="$SURFACE1"

EMPTY_DRAWING="off"

SPACE_EVENTS="aerospace_workspace_change front_app_switched"

get_workspace_item_name() {
  local workspace_id="$1"
  printf "space.%s" "$workspace_id"
}

is_workspace_occupied() {
  local workspace_id="$1"
  printf "%s\n" "$OCCUPIED_WORKSPACES" | grep -qx "$workspace_id"
}

ensure_space_item_exists() {
  local workspace_id="$1"
  local item_name

  [ -z "$workspace_id" ] && return

  item_name="$(get_workspace_item_name "$workspace_id")"

  if sketchybar --query "$item_name" >/dev/null 2>&1; then
    return
  fi

  sketchybar --add item "$item_name" left \
    --set "$item_name" \
    icon="$workspace_id" \
    icon.font="$SPACE_ICON_FONT" \
    icon.color=$OVERLAY1 \
    icon.padding_left=$SPACE_ICON_PADDING_LEFT \
    icon.padding_right=$SPACE_ICON_PADDING_RIGHT \
    label.drawing=off \
    background.color=$TRANSPARENT \
    background.corner_radius=$SPACE_BG_CORNER_RADIUS \
     background.height=$SPACE_BG_HEIGHT \
     background.border_width=$SPACE_BG_BORDER_WIDTH \
     background.border_color=$SURFACE0 \
     click_script="aerospace workspace $workspace_id" \
     script="$CONFIG_DIR/plugins/aerospace.sh $workspace_id"

  sketchybar --subscribe "$item_name" $SPACE_EVENTS
}

get_workspace_state() {
  local workspace_id="$1"

  if [ "$workspace_id" = "$FOCUSED_WORKSPACE" ]; then
    printf "%s" "$STATE_FOCUSED"
    return
  fi

  if is_workspace_occupied "$workspace_id"; then
    printf "%s" "$STATE_OCCUPIED"
    return
  fi

  printf "%s" "$STATE_EMPTY"
}

set_workspace_style() {
  local item_name="$1"
  local workspace_id="$2"
  local state

  state="$(get_workspace_state "$workspace_id")"

  if [ "$state" = "$STATE_FOCUSED" ]; then
    sketchybar --set "$item_name" \
      drawing=on \
      icon.color=$FOCUSED_ICON_COLOR \
      background.color=$FOCUSED_BG_COLOR \
      background.border_color=$FOCUSED_BORDER_COLOR \
      background.border_width=$SPACE_BG_BORDER_WIDTH
    return
  fi

  if [ "$state" = "$STATE_OCCUPIED" ]; then
    sketchybar --set "$item_name" \
      drawing=on \
      icon.color=$OCCUPIED_ICON_COLOR \
      background.color=$OCCUPIED_BG_COLOR \
      background.border_color=$OCCUPIED_BORDER_COLOR \
      background.border_width=$SPACE_BG_BORDER_WIDTH
    return
  fi

  sketchybar --set "$item_name" drawing=$EMPTY_DRAWING
}

sync_all_workspaces() {
  local workspace_id
  local item_name

  for workspace_id in $ALL_WORKSPACES; do
    ensure_space_item_exists "$workspace_id"
    item_name="$(get_workspace_item_name "$workspace_id")"
    set_workspace_style "$item_name" "$workspace_id"
  done
}

sync_one_workspace() {
  local workspace_id="$1"
  local item_name

  [ -z "$workspace_id" ] && return

  ensure_space_item_exists "$workspace_id"

  item_name="$(get_workspace_item_name "$workspace_id")"
  if [ -n "$NAME" ]; then
    item_name="$NAME"
  fi

  set_workspace_style "$item_name" "$workspace_id"
}

FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null | tr -d '[:space:]')
OCCUPIED_WORKSPACES=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)

if [ "$TARGET_WORKSPACE" = "poll" ]; then
  ALL_WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)
  sync_all_workspaces
  exit 0
fi

sync_one_workspace "$TARGET_WORKSPACE"
