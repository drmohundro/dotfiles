#!/bin/bash
source "$CONFIG_DIR/colors.sh"

CACHE="/tmp/aerospace_focused_workspace"

# Keep cache up to date when workspace changes
if [ "$SENDER" = "aerospace_workspace_change" ]; then
  echo "$FOCUSED_WORKSPACE" > "$CACHE"
fi

FOCUSED="${FOCUSED_WORKSPACE:-$(cat "$CACHE" 2>/dev/null)}"

# Workspace items are named space.1 through space.7 (numeric)
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
    label="$APP" \
    label.color=$BASE \
    label.drawing=on
else
  sketchybar --set "$NAME" \
    background.color=$SURFACE0 \
    icon.color=$TEXT \
    label.drawing=off
fi
