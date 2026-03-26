#!/bin/bash
TRACK=$(osascript -e '
tell application "Music"
  if player state is playing then
    return (name of current track) & " - " & (artist of current track)
  end if
end tell
')

if [ -n "$TRACK" ]; then
  MAX_LEN=30
  if [ ${#TRACK} -gt $MAX_LEN ]; then
    TRACK="${TRACK:0:$MAX_LEN}…"
  fi
  sketchybar --set "$NAME" drawing=on label="$TRACK"
else
  sketchybar --set "$NAME" drawing=off
fi
