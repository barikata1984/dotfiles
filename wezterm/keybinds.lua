local wezterm = require("wezterm")
local act = wezterm.action

return {
	keys = {
		{ key = "h", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Left") },
		{ key = "LeftArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "l", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Right") },
		{ key = "RightArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "k", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Up") },
		{ key = "UpArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "j", mods = "SHIFT|CTRL", action = act.ActivatePaneDirection("Down") },
		{ key = "DownArrow", mods = "SHIFT|ALT|CTRL", action = act.AdjustPaneSize({ "Down", 1 }) },
	},
}
