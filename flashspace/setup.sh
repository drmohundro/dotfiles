#!/bin/bash
# FlashSpace workspace setup
# Run this once on each machine, or after changing monitors.
# Mirrors the AeroSpace workspace layout.
#
# After running, configure manually in FlashSpace → Integrations:
#   Before Workspace Change:
#     /opt/homebrew/bin/sketchybar --trigger flashspace_workspace_change WORKSPACE="$WORKSPACE" DISPLAY="$DISPLAY"
#   On Profile Change:
#     /opt/homebrew/bin/sketchybar --reload
#
# NOTE: Use full paths — GUI apps don't inherit shell PATH, so plain `sketchybar` won't be found.
#
# Workspaces:
#   1 coding  → main external monitor
#   2 browser → main external monitor
#   3 slack   → built-in
#   4 email   → built-in
#   5 music   → built-in
#   6 misc    → built-in
#   7 gaming  → main external monitor

BUILTIN="Built-in Retina Display"
MAIN=$(flashspace list-displays | grep -v "Built-in" | head -1)

if [ -z "$MAIN" ]; then
  echo "No external display detected — assigning all workspaces to built-in."
  MAIN="$BUILTIN"
fi

echo "Built-in: $BUILTIN"
echo "Main:     $MAIN"
echo ""

# Remove existing workspaces
for ws in $(flashspace list-workspaces 2>/dev/null); do
  echo "Removing workspace: $ws"
  flashspace delete-workspace "$ws"
done

# Create workspaces
# SF Symbols icons: https://developer.apple.com/sf-symbols/
# NOTE: Keyboard shortcuts must be set manually in FlashSpace → Workspaces settings.
#       The --activate-key CLI flag does not reliably bind modifier keys in the UI.
flashspace create-workspace "coding"  --display "$MAIN"    --icon "chevron.left.forwardslash.chevron.right"
flashspace create-workspace "browser" --display "$MAIN"    --icon "globe"
flashspace create-workspace "slack"   --display "$BUILTIN" --icon "bubble.left.and.bubble.right.fill"
flashspace create-workspace "email"   --display "$BUILTIN" --icon "envelope.fill"
flashspace create-workspace "music"   --display "$BUILTIN" --icon "music.note"
flashspace create-workspace "misc"    --display "$BUILTIN" --icon "tray.full.fill"
flashspace create-workspace "gaming"  --display "$MAIN"    --icon "gamecontroller.fill"

echo ""
echo "Assigning apps..."

# coding
flashspace assign-app --name "com.mitchellh.ghostty"         --workspace "coding"
flashspace assign-app --name "com.microsoft.VSCode"          --workspace "coding"
flashspace assign-app --name "com.microsoft.VSCodeInsiders"  --workspace "coding"
flashspace assign-app --name "com.jetbrains.rider"           --workspace "coding"
flashspace assign-app --name "com.jetbrains.datagrip"        --workspace "coding"
flashspace assign-app --name "com.jetbrains.intellij"        --workspace "coding"
flashspace assign-app --name "com.jetbrains.webstorm"        --workspace "coding"
flashspace assign-app --name "com.jetbrains.pycharm"         --workspace "coding"
flashspace assign-app --name "com.jetbrains.goland"          --workspace "coding"

# slack
flashspace assign-app --name "com.tinyspeck.slackmacOS"      --workspace "slack"

# email
flashspace assign-app --name "com.apple.mail"                --workspace "email"
flashspace assign-app --name "com.apple.iCal"                --workspace "email"

# music
flashspace assign-app --name "com.apple.Music"               --workspace "music"

# gaming
flashspace assign-app --name "com.valvesoftware.steam"        --workspace "gaming"
flashspace assign-app --name "com.codeweavers.CrossOver"      --workspace "gaming"

# floating apps (no workspace assignment, managed by FlashSpace floating-apps)
flashspace floating-apps float --name "com.1password.1password"
flashspace floating-apps float --name "com.culturedcode.ThingsMac"

echo ""
echo "Done! Run 'sketchybar --reload' to refresh the bar."
