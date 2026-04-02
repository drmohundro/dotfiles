#!/bin/bash

STATE=$(osascript -e 'tell application "Music" to return player state as text' 2>/dev/null)

if [ "$STATE" != "playing" ] && [ "$STATE" != "paused" ]; then
  sketchybar --set media drawing=off popup.drawing=off
  exit 0
fi

TITLE=$(osascript  -e 'tell application "Music" to return name of current track'   2>/dev/null)
ARTIST=$(osascript -e 'tell application "Music" to return artist of current track'  2>/dev/null)
ALBUM=$(osascript  -e 'tell application "Music" to return album of current track'   2>/dev/null)

# Write album art: AppleScript returns hex like «data JPEGFFD8FF...» or «data PNGf8950...»
# Strip the type-code prefix and trailing », decode hex to binary, resize to 100x100.
osascript \
  -e 'tell application "Music"' \
  -e 'return data of artwork 1 of current track' \
  -e 'end tell' 2>/dev/null \
  | sed 's/.*data [A-Za-z0-9]\{4\}//' | tr -d '» \n' \
  | xxd -r -p > /tmp/sketchybar_album_art.jpg
sips -z 200 200 /tmp/sketchybar_album_art.jpg &>/dev/null

# Bar item
DISPLAY="$TITLE"
[ ${#DISPLAY} -gt 30 ] && DISPLAY="${DISPLAY:0:30}…"
sketchybar --set media drawing=on label="$DISPLAY"

# Popup content
sketchybar --set media.art    background.image.string="/tmp/sketchybar_album_art.jpg"
sketchybar --set media.title  label="$TITLE"
sketchybar --set media.artist label="$ARTIST"
sketchybar --set media.album  label="$ALBUM"

if [ "$STATE" = "playing" ]; then
  sketchybar --set media.playpause icon=󰏤
else
  sketchybar --set media.playpause icon=󰐊
fi
