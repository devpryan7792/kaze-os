-- ==============================================================================
-- KAZE KASUMI: WINDOW RULES & LAYER RULES (hypr/lua/window-rules.lua)
-- ==============================================================================

return {
    window_rules = {
        -- Floating Utility Dialogs
        "float, class:^(pavucontrol)$",
        "float, class:^(blueman-manager)$",
        "float, class:^(nm-connection-editor)$",
        "float, class:^(kaze-welcome)$",
        "float, class:^(calamares)$",
        "float, title:^(Open File)$",
        "float, title:^(Save File)$",
        "float, title:^(Choose Wallpaper)$",

        -- Picture-in-Picture
        "float, title:^(Picture-in-Picture)$",
        "pin, title:^(Picture-in-Picture)$",
        "size 640 360, title:^(Picture-in-Picture)$",

        -- Polkit Agent
        "float, class:^(polkit-kde-authentication-agent-1)$",
        "dimaround, class:^(polkit-kde-authentication-agent-1)$",

        -- Opacity Overrides
        "opacity 0.94 0.88, class:^(ghostty)$",
        "opacity 1.0 1.0, class:^(firefox)$",
        "opacity 1.0 1.0, class:^(chromium)$",
        "opacity 1.0 1.0, class:^(mpv)$",

        -- Idle Inhibitor for Fullscreen Media
        "idleinhibit fullscreen, class:^(.*)$"
    },
    layer_rules = {
        -- Blur and animations for QuickShell layers
        "blur, quickshell:.*",
        "ignorezero, quickshell:.*",
        "blur, notifications",
        "ignorezero, notifications"
    }
}
