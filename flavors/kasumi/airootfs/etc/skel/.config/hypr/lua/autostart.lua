-- ==============================================================================
-- KAZE KASUMI: AUTOSTART DAEMONS (hypr/lua/autostart.lua)
-- ==============================================================================

return {
    exec_once = {
        -- Authentication agent
        "/usr/lib/polkit-kde-authentication-agent-1",

        -- Wallpaper daemon
        "awww-daemon",

        -- Unified desktop shell
        "quickshell",

        -- Idle & Screen locker
        "hypridle",

        -- Initial dynamic theming & wallpaper on login
        "kaze-cli wallpaper random",

        -- Clipboard manager daemon
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store"
    }
}
