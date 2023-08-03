-- Pull in the wezterm API
local wezterm = require('wezterm')

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'tokyonight_night'

config.font_size = 15.0
config.font = wezterm.font('JetBrainsMono Nerd Font')

if wezterm.target_triple == 'aarch64-apple-darwin' then
  config.default_prog = { '/opt/homebrew/bin/fish', '-l' }
else
  config.default_prog = { '/usr/local/bin/fish', '-l' }
end

config.hide_tab_bar_if_only_one_tab = true

config.keys = {
  {
    key = 'd',
    mods = 'CMD',
    action = wezterm.action.SplitHorizontal({}),
  },
  {
    key = 'd',
    mods = 'CMD|SHIFT',
    action = wezterm.action.SplitVertical({}),
  },
  {
    key = '[',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection('Prev'),
  },
  {
    key = ']',
    mods = 'CMD',
    action = wezterm.action.ActivatePaneDirection('Next'),
  },
  {
    key = 'w',
    mods = 'CMD',
    action = wezterm.action.CloseCurrentPane({ confirm = false }),
  },
}

-- and finally, return the configuration to wezterm
return config
