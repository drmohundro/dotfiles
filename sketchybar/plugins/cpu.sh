#!/bin/bash
USAGE=$(top -l 1 | grep "CPU usage" | awk '{printf "%.0f", $3}')
sketchybar --set  "$NAME" label="cpu ${USAGE}%"
sketchybar --push "$NAME" $(echo "$USAGE" | awk '{printf "%.2f", $1/100}')
