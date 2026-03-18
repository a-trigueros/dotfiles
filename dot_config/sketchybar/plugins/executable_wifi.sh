#!/bin/bash

# Plugin : wifi.sh
# macOS 15+ redacte le SSID sans entitlement spécial.
# On détecte le type de connexion et affiche l'IP.

source "$CONFIG_DIR/colors.sh"

# ─── Récupère l'IP active (hors loopback) ─────────────────
get_ip() {
  ipconfig getifaddr "$1" 2>/dev/null
}

# ─── 1. WiFi (en0 sur ce Mac) ─────────────────────────────
WIFI_IP=$(get_ip en0)
if [ -n "$WIFI_IP" ]; then
  sketchybar --set "$NAME" \
    icon="󰤨" \
    icon.color=$GREEN \
    label="$WIFI_IP"
  exit 0
fi

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
