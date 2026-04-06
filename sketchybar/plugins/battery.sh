#!/bin/bash
source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" label.drawing=on
  exit 0
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" label.drawing=off
  exit 0
fi

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep 'AC Power')

if [ -z "$PERCENTAGE" ]; then
  exit 0
fi

if [ -n "$CHARGING" ]; then
  ICON="􀢋"
  COLOR=$GREEN
else
  if [ "$PERCENTAGE" -ge 100 ]; then
    ICON="􀛨"
    COLOR=$TEXT
  elif [ "$PERCENTAGE" -ge 75 ]; then
    ICON="􀺸"
    COLOR=$TEXT
  elif [ "$PERCENTAGE" -ge 50 ]; then
    ICON="􀺶"
    COLOR=$TEXT
  elif [ "$PERCENTAGE" -ge 25 ]; then
    ICON="􀛩"
    COLOR=$YELLOW
  else
    ICON="􀛪"
    COLOR=$RED
  fi
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color=$COLOR \
  label="${PERCENTAGE}%" \
  label.color=$COLOR
