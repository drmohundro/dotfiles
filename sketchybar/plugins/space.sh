#!/bin/bash
source "$CONFIG_DIR/colors.sh"

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" \
    background.color=$MAUVE \
    icon.color=$BASE
else
  sketchybar --set "$NAME" \
    background.color=$SURFACE0 \
    icon.color=$TEXT
fi
