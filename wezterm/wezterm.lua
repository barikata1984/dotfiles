-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Colour
config.color_scheme = "Kanagawa (Gogh)"
-- config.color_scheme = "iceberg-dark"
-- config.color_scheme = "London Tube (base16)"
config.window_background_opacity = 0.9

-- Font
config.font = wezterm.font("FiraCode Nerd Font Mono")
config.font_size = 11

-- Custom key bindings
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables

-- and finally, return the configuration to wezterm
return config
