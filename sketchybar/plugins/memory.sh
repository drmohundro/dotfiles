#!/bin/bash
PAGE_SIZE=4096
STATS=$(vm_stat)

pages_active=$(echo "$STATS" | awk '/Pages active/ {gsub(/\./,""); print $3}')
pages_wired=$(echo "$STATS" | awk '/Pages wired down/ {gsub(/\./,""); print $4}')
pages_compressed=$(echo "$STATS" | awk '/Pages occupied by compressor/ {gsub(/\./,""); print $5}')

USED_GB=$(echo "$pages_active $pages_wired $pages_compressed" | awk -v ps=$PAGE_SIZE '{
  printf "%.1f", ($1 + $2 + $3) * ps / 1073741824
}')

sketchybar --set "$NAME" label="${USED_GB}GB"
