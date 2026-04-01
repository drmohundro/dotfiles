#!/bin/bash
source "$CONFIG_DIR/colors.sh"

CACHE="/tmp/flashspace_focused_workspace"

# Keep cache up to date when workspace changes
if [ "$SENDER" = "flashspace_workspace_change" ]; then
  echo "$WORKSPACE" > "$CACHE"
fi

FOCUSED="${WORKSPACE:-$(cat "$CACHE" 2>/dev/null)}"

WORKSPACE_NAMES=(coding browser slack email music misc gaming)
INDEX="${NAME#space.}"
WORKSPACE_NAME="${WORKSPACE_NAMES[$((INDEX-1))]}"

if [ "$WORKSPACE_NAME" = "$FOCUSED" ]; then
  APP="${INFO:-$(flashspace get-app 2>/dev/null)}"
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
