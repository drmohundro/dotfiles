#!/bin/bash

NUM_DISPLAYS=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -c "Resolution:")

if [ "$NUM_DISPLAYS" -gt 1 ]; then
  sketchybar \
    --set cpu       display=1 \
    --set memory    display=1 \
    --set net_icon  display=1 \
    --set net_speed display=1 \
    --set wifi_icon display=2
else
  sketchybar \
    --set net_icon  display=active \
    --set net_speed display=active \
    --set wifi_icon display=off \
    --set cpu       display=off \
    --set memory    display=off
fi
