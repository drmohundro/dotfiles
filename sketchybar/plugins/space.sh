#!/bin/bash
source "$CONFIG_DIR/colors.sh"

FOCUSED="${FOCUSED_WORKSPACE:-$(aerospace list-workspaces --focused 2>/dev/null)}"
WORKSPACE="${NAME#space.}"

if [ "$WORKSPACE" = "$FOCUSED" ]; then
  if [ "$SENDER" = "front_app_switched" ]; then
    APP="$INFO"
  else
    APP=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null | head -1)
  fi

  sketchybar --set "$NAME" \
    background.color=$MAUVE \
    icon.color=$BASE \
    label="${APP}" \
    label.color=$BASE \
    label.drawing=on
else
  sketchybar --set "$NAME" \
    background.color=$SURFACE0 \
    icon.color=$TEXT \
    label.drawing=off
fi
