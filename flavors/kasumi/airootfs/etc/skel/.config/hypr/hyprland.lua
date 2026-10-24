-- ==============================================================================
-- KAZE KASUMI: MASTER HYPRLAND ENTRYPOINT (hypr/hyprland.lua)
-- Unified Modular Lua Configuration for Kaze OS (風)
-- ==============================================================================

local colors       = require("lua.colors")
local settings     = require("lua.settings")
local devices      = require("lua.devices")
local binds        = require("lua.binds")
local window_rules = require("lua.window-rules")
local autostart    = require("lua.autostart")

return {
    colors       = colors,
    settings     = settings,
    devices      = devices,
    binds        = binds,
    window_rules = window_rules,
    autostart    = autostart
}
