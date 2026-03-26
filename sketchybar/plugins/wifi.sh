#!/bin/bash
source "$CONFIG_DIR/colors.sh"

WIFI_IF=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}')
IP=$(ipconfig getifaddr "$WIFI_IF" 2>/dev/null)

if [ -z "$IP" ]; then
  sketchybar --set "$NAME" icon="󰤭" icon.color=$RED label="Off" label.color=$RED
else
  sketchybar --set "$NAME" icon="󰤨" icon.color=$TEAL label="$IP" label.color=$TEXT
fi
