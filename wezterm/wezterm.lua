local wezterm = require("wezterm")
local launch_menu = {}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    table.insert(launch_menu, {
        label = "PowerShell 7",
        args = {
            "C:/Program Files/PowerShell/7/pwsh.exe",
            "-NoLogo",
        },
    })

    -- Find installed visual studio version(s) and add their compilation
    -- environment command prompts to the menu
    for _, vsvers in ipairs(wezterm.glob("Microsoft Visual Studio/20*", "C:/Program Files")) do
        local year = vsvers:gsub("Microsoft Visual Studio/", "")
        table.insert(launch_menu, {
            label = "x64 Native Tools VS " .. year,
            args = {
                "cmd.exe",
                "/k",
                "C:/Program Files/Microsoft Visual Studio/" .. year .. vsvers .. "/VC/Auxiliary/Build/vcvars64.bat",
            },
        })
    end
else
    table.insert(launch_menu, {
        -- Optional label to show in the launcher. If omitted, a label
        -- is derived from the `args`
        label = "Zsh",
        -- The argument array to spawn.  If omitted the default program
        -- will be used as described in the documentation above
        args = { "zsh", "-l" },

        -- You can specify an alternative current working directory;
        -- if you don't specify one then a default based on the OSC 7
        -- escape sequence will be used (see the Shell Integration
        -- docs), falling back to the home directory.
        -- cwd = "/some/path"

        -- You can override environment variables just for this command
        -- by setting this here.  It has the same semantics as the main
        -- set_environment_variables configuration option described above
        -- set_environment_variables = { FOO = "bar" },
    })
end

local config = wezterm.config_builder()
config.launch_menu = launch_menu

-- Colour
config.color_scheme = "Kanagawa (Gogh)"
config.window_background_opacity = 0.9

-- Font
config.font = wezterm.font_with_fallback({
    "FiraCode Nerd Font",
    "PingFang SC",
})
config.font_size = 11
-- Custom key bindings
config.keys = require("keybinds").keys

-- and finally, return the configuration to wezterm
return config
