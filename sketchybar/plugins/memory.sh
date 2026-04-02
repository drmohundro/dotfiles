#!/bin/bash
PAGE_SIZE=4096
STATS=$(vm_stat)

pages_active=$(echo "$STATS" | awk '/Pages active/ {gsub(/\./,""); print $3}')
pages_wired=$(echo "$STATS" | awk '/Pages wired down/ {gsub(/\./,""); print $4}')
pages_compressed=$(echo "$STATS" | awk '/Pages occupied by compressor/ {gsub(/\./,""); print $5}')

TOTAL_BYTES=$(sysctl -n hw.memsize)

RATIO=$(echo "$pages_active $pages_wired $pages_compressed $PAGE_SIZE $TOTAL_BYTES" | awk '{
  used = ($1 + $2 + $3) * $4
  printf "%.2f", used / $5
}')

PCT=$(echo "$RATIO" | awk '{printf "%d", $1 * 100}')

sketchybar --set  "$NAME" label="ram ${PCT}%"
sketchybar --push "$NAME" "$RATIO"
