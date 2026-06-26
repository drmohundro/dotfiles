#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugins_dir="$script_dir/plugins"
layouts_dir="$script_dir/layouts"
mo_template="$layouts_dir/mo.tmpl.kdl"
mo_layout="$layouts_dir/mo.kdl"

mkdir -p "$plugins_dir" "$layouts_dir"

curl -L -o "$plugins_dir/zjstatus.wasm" \
  https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm

# Catppuccin Mocha Base16 colors, matching Stylix's catppuccin-mocha.yaml.
export base00="1e1e2e" # base
export base01="181825" # mantle
export base02="313244" # surface0
export base03="45475a" # surface1
export base04="585b70" # surface2
export base05="cdd6f4" # text
export base07="b4befe" # lavender
export base08="f38ba8" # red
export base09="fab387" # peach
export base0A="f9e2af" # yellow
export base0B="a6e3a1" # green
export base0D="89b4fa" # blue
export base0E="cba6f7" # mauve
export base0F="f2cdcd" # flamingo
export border="6c7086" # overlay0
export home="$HOME"

if [[ ! -f "$mo_template" ]]; then
  printf 'Missing template: %s\n' "$mo_template" >&2
  exit 1
fi

# Render ${var} placeholders from the exported color variables above.
# Uses Python's stdlib string.Template so we don't need gomplate/jinja/envsubst.
python3 - "$mo_template" "$mo_layout" <<'PY'
import os
import sys
from pathlib import Path
from string import Template

template_path = Path(sys.argv[1])
layout_path = Path(sys.argv[2])

layout_path.write_text(Template(template_path.read_text()).substitute(os.environ))
PY

printf 'Initialized Zellij:\n'
printf '  plugin:   %s\n' "$plugins_dir/zjstatus.wasm"
printf '  template: %s\n' "$mo_template"
printf '  layout:   %s\n' "$mo_layout"
