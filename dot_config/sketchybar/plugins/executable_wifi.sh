#!/bin/bash

source "$CONFIG_DIR/colors.sh"

TARGET_ITEM="$NAME"

ICON_WIFI="󰤨"
ICON_HOTSPOT="󰏲"
ICON_ETHERNET="󰈀"
ICON_OFFLINE="󰤭"

COLOR_WIFI="$GREEN"
COLOR_HOTSPOT="$MAUVE"
COLOR_ETHERNET="$SAPPHIRE"
COLOR_OFFLINE="$RED"

LABEL_HOTSPOT="iPhone"
LABEL_OFFLINE="Hors ligne"

WIFI_IFACES="en0"
HOTSPOT_IFACES="en4 en5 en6"
ETHERNET_IFACES="en1 en2 en3 en4 en5 en6"

get_ip_for_interface() {
  local iface="$1"
  ipconfig getifaddr "$iface" 2>/dev/null
}

get_hardware_port_for_interface() {
  local iface="$1"
  networksetup -listallhardwareports 2>/dev/null | grep -B1 "Device: $iface" | grep "Hardware Port" | cut -d: -f2- | xargs
}

is_hotspot_service() {
  local service_name="$1"
  printf "%s\n" "$service_name" | grep -Eqi "iphone|hotspot|partage"
}

set_network_item() {
  local icon="$1"
  local color="$2"
  local label="$3"

  sketchybar --set "$TARGET_ITEM" \
    icon="$icon" \
    icon.color=$color \
    label="$label"
}

try_set_wifi_item() {
  local iface
  local ip

  for iface in $WIFI_IFACES; do
    ip="$(get_ip_for_interface "$iface")"
    if [ -n "$ip" ]; then
      set_network_item "$ICON_WIFI" "$COLOR_WIFI" "$ip"
      return 0
    fi
  done

  return 1
}

try_set_hotspot_item() {
  local iface
  local service
  local ip

  for iface in $HOTSPOT_IFACES; do
    service="$(get_hardware_port_for_interface "$iface")"
    if ! is_hotspot_service "$service"; then
      continue
    fi

    ip="$(get_ip_for_interface "$iface")"
    if [ -n "$ip" ]; then
      set_network_item "$ICON_HOTSPOT" "$COLOR_HOTSPOT" "$LABEL_HOTSPOT"
      return 0
    fi
  done

  return 1
}

try_set_ethernet_item() {
  local iface
  local ip

  for iface in $ETHERNET_IFACES; do
    ip="$(get_ip_for_interface "$iface")"
    if [ -n "$ip" ]; then
      set_network_item "$ICON_ETHERNET" "$COLOR_ETHERNET" "$ip"
      return 0
    fi
  done

  return 1
}

set_offline_item() {
  set_network_item "$ICON_OFFLINE" "$COLOR_OFFLINE" "$LABEL_OFFLINE"
}

if try_set_wifi_item; then
  exit 0
fi

if try_set_hotspot_item; then
  exit 0
fi

if try_set_ethernet_item; then
  exit 0
fi

set_offline_item

# ─── 2. Partage iPhone ────────────────────────────────────
for iface in en4 en5 en6; do
  SERVICE=$(networksetup -listallhardwareports 2>/dev/null |
    grep -B1 "Device: $iface" |
    grep "Hardware Port" |
    cut -d: -f2- | xargs)
  if echo "$SERVICE" | grep -qi "iphone\|hotspot\|partage"; then
    IP=$(get_ip "$iface")
    if [ -n "$IP" ]; then
      sketchybar --set "$NAME" \
        icon="󰏲" \
        icon.color=$MAUVE \
        label="iPhone"
      exit 0
    fi
  fi
done

# ─── 3. Ethernet / Thunderbolt ────────────────────────────
for iface in en1 en2 en3 en4 en5 en6; do
  IP=$(get_ip "$iface")
  if [ -n "$IP" ]; then
    sketchybar --set "$NAME" \
      icon="󰈀" \
      icon.color=$SAPPHIRE \
      label="$IP"
    exit 0
  fi
done

# ─── 4. Hors ligne ────────────────────────────────────────
sketchybar --set "$NAME" \
  icon="󰤭" \
  icon.color=$RED \
  label="Hors ligne"
