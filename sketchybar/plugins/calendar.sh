#!/bin/bash
source "$CONFIG_DIR/colors.sh"

NEXT=$(swift "$CONFIG_DIR/plugins/nextMeeting.swift" 2>/dev/null)

if [ -z "$NEXT" ] || [ "$NEXT" = "No upcoming meetings" ]; then
  sketchybar --set "$NAME" drawing=off
else
  MAX_LEN=28
  if [ ${#NEXT} -gt $MAX_LEN ]; then
    NEXT="${NEXT:0:$MAX_LEN}…"
  fi
  sketchybar --set "$NAME" drawing=on label="$NEXT"
fi
