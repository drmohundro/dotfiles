#!/bin/bash
source "$CONFIG_DIR/colors.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

if [ -n "$CHARGING" ]; then
  ICON="󰂄"
  COLOR=$GREEN
else
  case "${PERCENTAGE}" in
    9[0-9]|100) ICON="󰁹"; COLOR=$GREEN ;;
    [6-8][0-9])  ICON="󰂁"; COLOR=$GREEN ;;
    [3-5][0-9])  ICON="󰁾"; COLOR=$YELLOW ;;
    [1-2][0-9])  ICON="󰁻"; COLOR=$YELLOW ;;
    *)           ICON="󰁺"; COLOR=$RED ;;
  esac
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color=$COLOR \
  label="${PERCENTAGE}%" \
  label.color=$COLOR
