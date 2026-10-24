-- ==============================================================================
-- KAZE KASUMI: HYPRLAND SETTINGS & ANIMATIONS (hypr/lua/settings.lua)
-- ==============================================================================

local colors = require("lua.colors")

return {
    monitors = {
        ",preferred,auto,1"
    },
    general = {
        gaps_in = 6,
        gaps_out = 12,
        border_size = 2,
        col_active_border = colors.active_border_1 .. " " .. colors.active_border_2 .. " 45deg",
        col_inactive_border = colors.inactive_border,
        layout = "dwindle",
        allow_tearing = false
    },
    decoration = {
        rounding = 10,
        active_opacity = 0.96,
        inactive_opacity = 0.88,
        fullscreen_opacity = 1.0,
        blur = {
            enabled = true,
            size = 8,
            passes = 3,
            new_optimizations = true,
            xray = false,
            ignore_opacity = true
        },
        shadow = {
            enabled = true,
            range = 24,
            render_power = 3,
            color = colors.shadow
        }
    },
    animations = {
        enabled = true,
        beziers = {
            { name = "fluid", values = "0.05, 0.9, 0.1, 1.05" },
            { name = "overshot", values = "0.13, 0.99, 0.29, 1.1" },
            { name = "linear", values = "0.0, 0.0, 1.0, 1.0" }
        },
        rules = {
            "windows, 1, 5, overshot, slide",
            "windowsOut, 1, 4, default, popin 80%",
            "border, 1, 10, default",
            "borderangle, 1, 8, linear, loop",
            "fade, 1, 4, default",
            "workspaces, 1, 5, fluid, slide"
        }
    },
    dwindle = {
        pseudotile = true,
        preserve_split = true
    },
    gestures = {
        workspace_swipe = true,
        workspace_swipe_fingers = 3
    }
}
