#!/bin/bash
source "$CONFIG_DIR/colors.sh"

if [ "$SENDER" = "mouse.entered" ]; then
  sketchybar --set "$NAME" label.drawing=on
  exit 0
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" label.drawing=off
  exit 0
fi

if [ "$SENDER" = "volume_change" ]; then
  VOLUME="$INFO"

  if [ "$VOLUME" -ge 100 ]; then
    ICON="􀊩"
  elif [ "$VOLUME" -ge 66 ]; then
    ICON="􀊧"
  elif [ "$VOLUME" -ge 33 ]; then
    ICON="􀊥"
  elif [ "$VOLUME" -gt 10 ]; then
    ICON="􀊡"
  else
    ICON="􀊣"
  fi

  sketchybar --set "$NAME" icon="$ICON" icon.color=$TEXT label="${VOLUME}%"
fi
