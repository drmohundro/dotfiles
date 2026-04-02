#!/bin/bash

INTERFACE=$(route get default 2>/dev/null | awk '/interface:/{print $2}')
INTERNAL_IP=$(ipconfig getifaddr "${INTERFACE:-en0}" 2>/dev/null || echo "---")
PUBLIC_IP=$(curl -sf --max-time 5 https://api.ipify.org 2>/dev/null || echo "---")

sketchybar --set net_speed \
  icon="$PUBLIC_IP" \
  label="$INTERNAL_IP"
