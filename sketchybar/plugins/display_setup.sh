#!/bin/bash

NUM_DISPLAYS=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -c "Resolution:")

if [ "$NUM_DISPLAYS" -gt 1 ]; then
  # External monitor connected: full info on display 1, condensed on display 2
  sketchybar --set cpu    display=1
  sketchybar --set memory display=1
  sketchybar --set wifi   display=1
  sketchybar --set wifi_icon display=2
else
  # Laptop only: condensed layout on the single display
  sketchybar --set cpu    display=off
  sketchybar --set memory display=off
  sketchybar --set wifi   display=off
  sketchybar --set wifi_icon display=all
fi
