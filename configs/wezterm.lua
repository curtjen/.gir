-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices.

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.initial_rows = 28


config.font = wezterm.font_with_fallback { 'Source Code Pro for Powerline', 'Comic Sans MS'}
config.font_size = 14
-- config.color_scheme = 'AdventureTime'
-- config.color_scheme = 'Solarized (light)'
config.color_scheme = 'Afterglow'
-- config.color_scheme = 'Batman'
config.colors = {
  selection_fg = 'Black',
  selection_bg = 'Lime',
  visual_bell = 'rgba(0,0,0,0.25)'
}

-- ERROR BELL --

config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_function = 'EaseIn',
  fade_in_duration_ms = 150,
  fade_out_function = 'EaseOut',
  fade_out_duration_ms = 150,
--  target = 'CursorColor'
}

-- Finally, return the configuration to wezterm:
return config
