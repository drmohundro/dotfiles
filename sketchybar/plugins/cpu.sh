#!/bin/bash
USAGE=$(top -l 1 | grep "CPU usage" | awk '{printf "%.0f", $3}')
sketchybar --set "$NAME" label="${USAGE}%"
